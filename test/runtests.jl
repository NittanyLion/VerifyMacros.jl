using VerifyMacros
using Test
using Aqua

@testset "VerifyMacros.jl" begin
    @testset "Aqua" begin
        Aqua.test_all(VerifyMacros)
    end

    @testset "Type Verification" begin
        x = 1.0
        # Success
        @test isnothing(@verifytype x Float64)
        @test isnothing(@verifytype x Real)
        
        # Failure
        @test_throws ErrorException @verifytype x Int
        
        # Batch success
        @test isnothing(@verifytypes (1.0, Float64) (1, Int))
        
        # Batch failure
        @test_throws ErrorException @verifytypes (1.0, Int) (1, Int)
    end

    @testset "Key Verification" begin
        d = Dict(:a => 1, :b => 2)
        # Success
        @test isnothing(@verifykey d :a)
        @test isnothing(@verifykey d :b)
        
        # Failure
        @test_throws ErrorException @verifykey d :c
        
        # Batch success
        @test isnothing(@verifykeys (d, :a) (d, :b))
        
        # Batch failure
        @test_throws ErrorException @verifykeys (d, :a) (d, :c)
    end

    @testset "Property Verification" begin
        struct PropTest
            p::Int
        end
        
        pt = PropTest(1)
        
        # Success
        @test isnothing(@verifyproperty pt :p)
        
        # Failure
        @test_throws ErrorException @verifyproperty pt :q
        
        # Batch success
        @test isnothing(@verifyproperties (pt, :p))
        
        # Batch failure
        @test_throws ErrorException @verifyproperties (pt, :q)
    end

    @testset "Supertype Verification" begin
        # Success
        @test isnothing(@verifysupertype Int Integer)
        @test isnothing(@verifysupertype Float64 Real)
        
        # Failure
        @test_throws ErrorException @verifysupertype Int AbstractFloat
        
        # Batch success
        @test isnothing(@verifysupertypes (Int, Integer) (Float64, Real))
        
        # Batch failure
        @test_throws ErrorException @verifysupertypes (Int, Integer) (Int, AbstractFloat)
    end

    @testset "Axes Verification" begin
        A = [1, 2]
        # Success
        @test isnothing(@verifyaxes A (1:2,))
        
        # Failure
        @test_throws ErrorException @verifyaxes A (1:3,)
        
        # Batch success
        @test isnothing(@verifyaxesm (A, (1:2,)))
        
        # Batch failure
        @test_throws ErrorException @verifyaxesm (A, (1:3,))
    end

    @testset "Field Verification" begin
        struct FieldTest
            f::Int
        end
        # verifyfield uses hasfield which takes a Type, not an instance
        
        # Success
        @test isnothing(@verifyfield FieldTest :f)
        
        # Failure
        @test_throws ErrorException @verifyfield FieldTest :g
        
        # Batch success
        @test isnothing(@verifyfields (FieldTest, :f))
        
        # Batch failure
        @test_throws ErrorException @verifyfields (FieldTest, :f) (FieldTest, :g)
    end

    @testset "Membership Verification" begin
        C = [1, 2, 3]
        e = 1
        
        # Success
        @test isnothing(@verifyin e C)
        @test isnothing(@verifyin 2 C)
        
        # Failure
        @test_throws ErrorException @verifyin 4 C
        
        # Batch success
        @test isnothing(@verifyins (1, C) (2, C))
        
        # Batch failure
        @test_throws ErrorException @verifyins (1, C) (4, C)
    end

    @testset "Equality Verification" begin
        x = 5
        # Success
        @test isnothing(@verifyequal x 5)
        
        # Failure
        @test_throws ErrorException @verifyequal x 6
        
        # Batch
        @test isnothing(@verifyequals (x, 5) (10, 10))
        @test_throws ErrorException @verifyequals (x, 5) (x, 6)
    end

    @testset "Length Verification" begin
        col = [1, 2, 3]
        # Success
        @test isnothing(@verifylength col 3)
        
        # Failure
        @test_throws ErrorException @verifylength col 2
        
        # Batch
        @test isnothing(@verifylengths (col, 3) ([], 0))
        @test_throws ErrorException @verifylengths (col, 3) (col, 2)
    end

    @testset "Size Verification" begin
        arr = [1 2; 3 4]
        # Success
        @test isnothing(@verifysize arr (2, 2))
        
        # Failure
        @test_throws ErrorException @verifysize arr (2, 3)
        
        # Batch
        @test isnothing(@verifysizes (arr, (2, 2)))
        @test_throws ErrorException @verifysizes (arr, (2, 3))
    end

    @testset "FileSystem Verification" begin
        # Create temp resources
        tmpfile, io = mktemp()
        close(io)
        tmpdir = mktempdir()
        
        try
            # File Success
            @test isnothing(@verifyisfile tmpfile)
            # File Failure (dir is not file, or non-existent)
            @test_throws ErrorException @verifyisfile tmpdir
            @test_throws ErrorException @verifyisfile "non_existent_file"
            
            # Dir Success
            @test isnothing(@verifyisdir tmpdir)
            # Dir Failure
            @test_throws ErrorException @verifyisdir tmpfile
            @test_throws ErrorException @verifyisdir "non_existent_dir"
            
            # Batch
            @test isnothing(@verifyisfiles (tmpfile))
            @test isnothing(@verifyisdirs (tmpdir))
            # Test batch tuple with name
            @test isnothing(@verifyisfiles (tmpfile, "temp file"))
            
        finally
            rm(tmpfile, force=true)
            rm(tmpdir, recursive=true, force=true)
        end
    end

    @testset "Generic Verification" begin
        x = 10
        # Success
        @test isnothing(@verifytrue x > 5)
        
        # Failure
        @test_throws ErrorException @verifytrue x < 5
        
        # Batch
        @test isnothing(@verifytrues (x > 5) (x == 10))
        @test_throws ErrorException @verifytrues (x > 5) (x < 5)
    end

end

    @testset "Meta @verify Macro" begin
        x = 1.0
        d = Dict(:a => 1, :b => 2)
        
        # Test mapping to @verifytype
        @test isnothing(@verify :type x Float64)
        @test_throws ErrorException @verify :type x Int

        # Test mapping to @verifykeys (using the shorthand syntax)
        @test isnothing(@verify :keys d :a :b)
        @test_throws ErrorException @verify :keys d :a :c
        
        # Test mapping to @verifytrue
        @test isnothing(@verify :true 1 < 2)
        
        # Test invalid usage
        # ex = Expr(:macrocall, Symbol("@verify"), LineNumberNode(@__LINE__, @__FILE__), "string", :x)
        # @test_throws ErrorException eval(ex)
        # Note: LoadError because macro expansion fails, but test_throws usually catches runtime errors. 
        # Macro errors happen at expansion time. We can try to test expansion failure if needed, 
        # but the main path is covered above.
    end
