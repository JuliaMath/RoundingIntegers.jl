using Test
using RoundingIntegers
@test isempty(detect_ambiguities(Base, Core, RoundingIntegers))

@testset "Basics" begin
    r16 = RInt16(3)
    @test isa(r16, RInt16)
    r = RInt(5)
    @test isa(r, RInt)
    x = Integer(r)
    @test x === 5
    @test isa(convert(RUInt8, 2), RUInt8)
    @test -7 % RUInt8 === RUInt8(0xf9)
    @test convert(RInteger, 3) === RInt(3)
    @test convert(RInteger, 0x03) === RUInt8(3)

    @test typemin(RInt16) === RInt16(typemin(Int16))
    @test typemin(RInt32) === RInt32(typemin(Int32))
    @test widen(r16) === convert(RInt32, r16)

    @test !(r < r)
    @test r <= r
    @test !(r > r)
    @test r >= r
    @test !isless(r, r)

    @test isa(+r, RInt) && +r ==  5
    @test isa(-r, RInt) && -r == -5
    @test ~r16 === RInt16(-4)
    @test r << 2 === RInt(20)
    @test r >> 1 === RInt(2)
    @test r >>> 2 === RInt(1)
    @test RInt16(-5) >>> 3  === RInt16(8191)

    @test r16+r16 === RInt16(6)
    @test r16+r === 8
    @test r-r === RInt(0)
    @test r-r16 === 2
    @test r*r === RInt(25)
    @test 2*r === 10
    @test r*r16 === 15
    @test r/r === 1.0
    @test inv(r16) === inv(Int16(3))
    @test xor(r, r) === RInt(0)
    @test r & r === r
    @test r | r === r
    @test r ÷ r === RInt(1)
    @test r % r === RInt(0)

    @test fld(r, r) === 1
    @test cld(r, r) === 1

    @test isodd(r)
    @test !iseven(r16)
    @test !signbit(r)
    @test copysign(r, r) === r
    @test unsigned(r) === RUInt(5)
    @test string(r, base=16) == "5"

    @test string(RInt(7.2)) == "7"
end

@testset "Rounding" begin
    @test RInt(17.3) == 17
    @test RInt(17.8) == 18
    a = RUInt8[2,3]
    a[1] = 5.7
    @test a[1] === RUInt8(6)
end

nothing
