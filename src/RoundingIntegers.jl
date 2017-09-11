__precompile__(true)

module RoundingIntegers

using Compat
import Base: <, <=, +, -, *, ~, &, |, $, <<, >>, >>>

export RSigned, RUnsigned, RInteger
export RInt8, RUInt8, RInt16, RUInt16, RInt32, RUInt32, RInt64, RUInt64,
       RInt128, RUInt128, RInt, RUInt

@compat abstract type RSigned   <: Signed end
@compat abstract type RUnsigned <: Unsigned end

const RInteger = Union{RSigned,RUnsigned}

@compat primitive type RInt8 <: RSigned 8 end
@compat primitive type RUInt8 <: RUnsigned 8 end
@compat primitive type RInt16 <: RSigned 16 end
@compat primitive type RUInt16 <: RUnsigned 16 end
@compat primitive type RInt32 <: RSigned 32 end
@compat primitive type RUInt32 <: RUnsigned 32 end
@compat primitive type RInt64 <: RSigned 64 end
@compat primitive type RUInt64 <: RUnsigned 64 end
@compat primitive type RInt128 <: RSigned 128 end
@compat primitive type RUInt128 <: RUnsigned 128 end

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

Base.promote_rule{T<:Number,RI<:RInteger}(::Type{T}, ::Type{RI}) =
    promote_type(T, itype(RI))
# Resolve ambiguities
Base.promote_rule{RI<:RInteger}(::Type{Bool}, ::Type{RI}) =
    promote_type(Bool, itype(RI))
Base.promote_rule{RI<:RInteger}(::Type{BigInt}, ::Type{RI}) =
    promote_type(BigInt, itype(RI))
Base.promote_rule{RI<:RInteger}(::Type{BigFloat}, ::Type{RI}) =
    promote_type(BigFloat, itype(RI))
Base.promote_rule{T<:Real,RI<:RInteger}(::Type{Complex{T}}, ::Type{RI}) =
    promote_type(Complex{T}, itype(RI))
Base.promote_rule{T<:Integer,RI<:RInteger}(::Type{Rational{T}}, ::Type{RI}) =
    promote_type(Rational{T}, itype(RI))
@compat Base.promote_rule{RI<:RInteger}(::Type{<:Irrational}, ::Type{RI}) =
    promote_type(Float64, itype(RI))

(::Type{Signed})(x::RSigned) = reinterpret(itype(x), x)
(::Type{Unsigned})(x::RUnsigned) = reinterpret(itype(x), x)
(::Type{RSigned})(x::Signed) = reinterpret(rtype(x), x)
(::Type{RUnsigned})(x::Unsigned) = reinterpret(rtype(x), x)
(::Type{Integer})(x::RSigned) = Signed(x)
(::Type{Integer})(x::RUnsigned) = Unsigned(x)
(::Type{RInteger})(x::Signed) = RSigned(x)
(::Type{RInteger})(x::Unsigned) = RUnsigned(x)

# Basic conversions
# @inline Base.convert{T<:RSigned}(::Type{T}, x::T) = x
# @inline Base.convert{T<:RUnsigned}(::Type{T}, x::T) = x
@inline Base.convert{T<:RInteger}(::Type{T}, x::T) = x
@inline Base.convert{T<:RInteger}(::Type{T}, x::RInteger) =
    RInteger(convert(itype(T), Integer(x)))
@inline Base.convert{T<:RInteger}(::Type{T}, x::Integer) = RInteger(convert(itype(T), x))
@inline Base.convert{T<:RInteger}(::Type{T}, x::AbstractFloat) =
    RInteger(round(itype(T), x))
@inline Base.convert{T<:RInteger}(::Type{T}, x::Number) =
    convert(T, convert(itype(T), x))

@inline Base.convert{T<:Number}(::Type{T}, x::RInteger) = convert(T, Integer(x))

# Resolve ambiguities
Base.convert(::Type{Integer}, x::RInteger) = Integer(x)
Base.convert(::Type{BigInt}, x::RInteger) = convert(BigInt, Integer(x))
Base.convert{T<:RInteger}(::Type{T}, x::BigInt) = RInteger(convert(itype(T), x))
Base.convert(::Type{BigFloat}, x::RInteger) = convert(BigFloat, Integer(x))
Base.convert{T<:RInteger}(::Type{T}, x::BigFloat) = RInteger(convert(itype(T), x))
Base.convert{T<:Real}(::Type{Complex{T}}, x::RInteger) = convert(Complex{T}, Integer(x))
Base.convert{T<:RInteger}(::Type{T}, z::Complex) = RInteger(convert(itype(T), z))
Base.convert(::Type{Complex}, x::RInteger) = Complex(x)
Base.convert{T<:RInteger}(::Type{T}, x::Rational) = RInteger(convert(itype(T)), x)
Base.convert{T<:Integer}(::Type{Rational{T}}, x::RInteger) =
    convert(Rational{T}, Integer(x))
Base.convert(::Type{Rational}, x::RInteger) = convert(Rational{typeof(x)}, x)
Base.convert(::Type{Float16}, x::RInteger) = convert(Float16, Integer(x))
Base.convert{T<:RInteger}(::Type{T}, x::Float16) = RInteger(convert(itype(T), x))
Base.convert(::Type{Bool}, x::RInteger) = convert(Bool, Integer(x))

# rem conversions
@inline Base.rem{T<:RInteger}(x::T, ::Type{T}) = T
@inline Base.rem{T<:RInteger}(x::Integer, ::Type{T}) = RInteger(rem(x, itype(T)))
# ambs
@inline Base.rem{T<:RInteger}(x::BigInt, ::Type{T}) = error("no rounding BigInt available")


Base.flipsign(x::RSigned, y::RSigned) = RInteger(flipsign(Integer(x), Integer(y)))

<(x::RInteger, y::RInteger) = Integer(x) < Integer(y)
<=(x::RInteger, y::RInteger) = Integer(x) <= Integer(y)

Base.count_ones(x::RInteger) = count_ones(Integer(x))
Base.leading_zeros(x::RInteger) = leading_zeros(Integer(x))
Base.trailing_zeros(x::RInteger) = trailing_zeros(Integer(x))
Base.ndigits0z(x::RInteger) = Base.ndigits0z(Integer(x))

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

+{T<:RInteger}(x::T, y::T) = RInteger(Integer(x) + Integer(y))
-{T<:RInteger}(x::T, y::T) = RInteger(Integer(x) - Integer(y))
*{T<:RInteger}(x::T, y::T) = RInteger(Integer(x) * Integer(y))
(&){T<:RInteger}(x::T, y::T) = RInteger(Integer(x) & Integer(y))
(|){T<:RInteger}(x::T, y::T) = RInteger(Integer(x) | Integer(y))
# ($){T<:RInteger}(x::T, y::T) = RInteger(Integer(x) $ Integer(y))
Compat.xor{T<:RInteger}(x::T, y::T) = RInteger(xor(Integer(x), Integer(y)))

Base.rem{T<:RInteger}(x::T, y::T) = RInteger(rem(Integer(x), Integer(y)))
Base.mod{T<:RInteger}(x::T, y::T) = RInteger(mod(Integer(x), Integer(y)))

Base.unsigned(x::RSigned) = RInteger(unsigned(Integer(x)))
Base.signed(x::RSigned)   = RInteger(signed(Integer(x)))

# traits
Base.typemin{T<:RInteger}(::Type{T}) = RInteger(typemin(itype(T)))
Base.typemax{T<:RInteger}(::Type{T}) = RInteger(typemax(itype(T)))
Base.widen{T<:RInteger}(::Type{T}) = rtype(widen(itype(T)))

end # module
