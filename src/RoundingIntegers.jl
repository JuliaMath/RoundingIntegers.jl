module RoundingIntegers

import Base: <, <=, +, -, *, ~, &, |, <<, >>, >>>, xor

export RSigned, RUnsigned, RInteger
export RInt8, RUInt8, RInt16, RUInt16, RInt32, RUInt32, RInt64, RUInt64,
       RInt128, RUInt128, RInt, RUInt

abstract type RSigned   <: Signed end
abstract type RUnsigned <: Unsigned end

const RInteger = Union{RSigned,RUnsigned}

primitive type RInt8 <: RSigned 8 end
primitive type RUInt8 <: RUnsigned 8 end
primitive type RInt16 <: RSigned 16 end
primitive type RUInt16 <: RUnsigned 16 end
primitive type RInt32 <: RSigned 32 end
primitive type RUInt32 <: RUnsigned 32 end
primitive type RInt64 <: RSigned 64 end
primitive type RUInt64 <: RUnsigned 64 end
primitive type RInt128 <: RSigned 128 end
primitive type RUInt128 <: RUnsigned 128 end

if Sys.WORD_SIZE == 32
    const RInt = RInt32
    const RUInt = RUInt32
else
    const RInt = RInt64
    const RUInt = RUInt64
end

itype(::Type{RInteger}) = Integer
itype(::Type{RSigned}) = Signed
itype(::Type{RUnsigned}) = Unsigned
itype(::Type{RInt8}) = Int8
itype(::Type{RUInt8}) = UInt8
itype(::Type{RInt16}) = Int16
itype(::Type{RUInt16}) = UInt16
itype(::Type{RInt32}) = Int32
itype(::Type{RUInt32}) = UInt32
itype(::Type{RInt64}) = Int64
itype(::Type{RUInt64}) = UInt64
itype(::Type{RInt128}) = Int128
itype(::Type{RUInt128}) = UInt128
itype(x::RInteger) = itype(typeof(x))

rtype(::Type{Signed}) = RSigned
rtype(::Type{Unsigned}) = RUnsigned
rtype(::Type{Int8}) = RInt8
rtype(::Type{UInt8}) = RUInt8
rtype(::Type{Int16}) = RInt16
rtype(::Type{UInt16}) = RUInt16
rtype(::Type{Int32}) = RInt32
rtype(::Type{UInt32}) = RUInt32
rtype(::Type{Int64}) = RInt64
rtype(::Type{UInt64}) = RUInt64
rtype(::Type{Int128}) = RInt128
rtype(::Type{UInt128}) = RUInt128
rtype(x::Union{Signed,Unsigned}) = rtype(typeof(x))

# RIntegers are largely about assignment; for usage, we convert to
# standard integers at the drop of a hat.

Base.promote_rule(::Type{RI}, ::Type{T}) where {T<:Number,RI<:RInteger} =
    promote_type(T, itype(RI))

Base.Signed(x::RSigned) = reinterpret(itype(x), x)
Base.Unsigned(x::RUnsigned) = reinterpret(itype(x), x)
RSigned(x::Signed) = reinterpret(rtype(x), x)
RUnsigned(x::Unsigned) = reinterpret(rtype(x), x)
Base.Integer(x::RSigned) = Signed(x)
Base.Integer(x::RUnsigned) = Unsigned(x)
RInteger(x::Signed) = RSigned(x)
RInteger(x::Unsigned) = RUnsigned(x)

Base.AbstractFloat(x::RInteger) = AbstractFloat(Integer(x))

RInt8(x::Int8) = reinterpret(RInt8, x)
RUInt8(x::UInt8) = reinterpret(RUInt8, x)
RInt16(x::Int16) = reinterpret(RInt16, x)
RUInt16(x::UInt16) = reinterpret(RUInt16, x)
RInt32(x::Int32) = reinterpret(RInt32, x)
RUInt32(x::UInt32) = reinterpret(RUInt32, x)
RInt64(x::Int64) = reinterpret(RInt64, x)
RUInt64(x::UInt64) = reinterpret(RUInt64, x)
RInt128(x::Int128) = reinterpret(RInt128, x)
RUInt128(x::UInt128) = reinterpret(RUInt128, x)

(::Type{R})(x::Integer) where R<:RInteger = R(convert(itype(R), x))
(::Type{R})(x::Float16) where R<:RInteger = R(round(itype(R), x))
(::Type{R})(x::BigFloat) where R<:RInteger = R(round(itype(R), x))
(::Type{R})(x::Rational) where R<:RInteger = R(round(itype(R), x))
(::Type{R})(x::Complex) where R<:RInteger = R(round(itype(R), x))
(::Type{R})(x::AbstractFloat) where R<:RInteger = R(round(itype(R), x))

@inline Base.convert(::Type{T}, x::RInteger) where {T<:Number} = convert(T, Integer(x))

# rem conversions
@inline Base.rem(x::T, ::Type{T}) where {T<:RInteger} = T
@inline Base.rem(x::Integer, ::Type{T}) where {T<:RInteger} = RInteger(rem(x, itype(T)))
# ambs
@inline Base.rem(x::BigInt, ::Type{T}) where {T<:RInteger} = error("no rounding BigInt available")


Base.flipsign(x::RSigned, y::RSigned) = RInteger(flipsign(Integer(x), Integer(y)))

<(x::RInteger, y::RInteger) = Integer(x) < Integer(y)
<=(x::RInteger, y::RInteger) = Integer(x) <= Integer(y)

Base.count_ones(x::RInteger) = count_ones(Integer(x))
Base.leading_zeros(x::RInteger) = leading_zeros(Integer(x))
Base.trailing_zeros(x::RInteger) = trailing_zeros(Integer(x))
Base.ndigits0z(x::RInteger) = Base.ndigits0z(Integer(x))
Base.ndigits0zpb(x::RSigned, b::Integer) = Base.ndigits0zpb(abs(Integer(x)), Int(b))
Base.ndigits0zpb(x::RUnsigned, b::Integer) = Base.ndigits0zpb(Integer(x), Int(b))

# A few operations preserve the type
-(x::RInteger) = RInteger(-Integer(x))
~(x::RInteger) = RInteger(~Integer(x))

>>(x::RInteger, y::Signed) = RInteger(Integer(x) >> y)
>>>(x::RInteger, y::Signed) = RInteger(Integer(x) >>> y)
<<(x::RInteger, y::Signed) = RInteger(Integer(x) << y)
>>(x::RInteger, y::Unsigned) = RInteger(Integer(x) >> y)
>>>(x::RInteger, y::Unsigned) = RInteger(Integer(x) >>> y)
<<(x::RInteger, y::Unsigned) = RInteger(Integer(x) << y)
# ambs
>>(x::RInteger, y::Int) = RInteger(Integer(x) >> y)
>>>(x::RInteger, y::Int) = RInteger(Integer(x) >>> y)
<<(x::RInteger, y::Int) = RInteger(Integer(x) << y)

+(x::T, y::T) where {T<:RInteger} = RInteger(Integer(x) + Integer(y))
-(x::T, y::T) where {T<:RInteger} = RInteger(Integer(x) - Integer(y))
*(x::T, y::T) where {T<:RInteger} = RInteger(Integer(x) * Integer(y))
(&)(x::T, y::T) where {T<:RInteger} = RInteger(Integer(x) & Integer(y))
(|)(x::T, y::T) where {T<:RInteger} = RInteger(Integer(x) | Integer(y))
xor(x::T, y::T) where {T<:RInteger} = RInteger(xor(Integer(x), Integer(y)))

Base.rem(x::T, y::T) where {T<:RInteger} = RInteger(rem(Integer(x), Integer(y)))
Base.mod(x::T, y::T) where {T<:RInteger} = RInteger(mod(Integer(x), Integer(y)))

Base.unsigned(x::RSigned) = RInteger(unsigned(Integer(x)))
Base.signed(x::RSigned)   = RInteger(signed(Integer(x)))

# traits
Base.typemin(::Type{T}) where {T<:RInteger} = RInteger(typemin(itype(T)))
Base.typemax(::Type{T}) where {T<:RInteger} = RInteger(typemax(itype(T)))
Base.widen(::Type{T}) where {T<:RInteger} = rtype(widen(itype(T)))

end # module
