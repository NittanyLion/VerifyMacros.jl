using VerifyMacros
using Test

@testset "VerifyMacros.jl" begin

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
        @test isnothing(@verifyaxes A (Base.OneTo(2),))
        
        # Failure
        @test_throws ErrorException @verifyaxes A (Base.OneTo(3),)
        
        # Batch success
        @test isnothing(@verifyaxes_list (A, (Base.OneTo(2),)))
        
        # Batch failure
        @test_throws ErrorException @verifyaxes_list (A, (Base.OneTo(3),))
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

end
