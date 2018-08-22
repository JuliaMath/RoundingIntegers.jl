# RoundingIntegers

[![Build Status](https://travis-ci.org/JuliaMath/RoundingIntegers.jl.svg?branch=master)](https://travis-ci.org/JuliaMath/RoundingIntegers.jl)

[![codecov.io](http://codecov.io/github/JuliaMath/RoundingIntegers.jl/coverage.svg?branch=master)](http://codecov.io/github/JuliaMath/RoundingIntegers.jl?branch=master)

RoundingIntegers defines new integer types for the Julia programming
language. Rounding integers act very much like regular integers,
except that you can safely assign floating-point values to them. As the name
suggests, such assignments cause rounding to the nearest integer.

Demonstration:
```julia
julia> using RoundingIntegers

julia> Int(7.2)     # fails with "regular" integers
ERROR: InexactError()
 in Int64(::Float64) at ./sysimg.jl:53

julia> RInt(7.2)    # but not with a rounding integer
7

julia> (map(RInt, 1.5:1:4.5)...,)  # rounds half integers to nearest even 
(2, 2, 4, 4)

julia> a = Vector{RUInt8}(undef, 2)
2-element Array{RoundingIntegers.RUInt8,1}:
 0x42
 0x61

julia> a[1] = 1.7
1.7

julia> a[2] = 128.1
128.1

julia> a
2-element Array{RoundingIntegers.RUInt8,1}:
 0x02
 0x80
```

The following types are available:
- `RInteger` (`RInteger(i)` converts `i` to the corresponding `RInteger` type)
- `RSigned`, `RUnsigned`
- `RInt8`, `RUInt8`
- `RInt16`, `RUInt16`
- `RInt32`, `RUInt32`
- `RInt64`, `RUInt64`
- `RInt128`, `RUInt128`
- `RInt`, `RUInt` (defaults to the platform's WORD_SIZE representation)

Most operations involving rounding integers promote to regular
integers. Only a small subset of operations (e.g., bit-shift operations,
negation, and certain arithmetic involving numbers of all the same
type) preserve the type of `RInteger`s.
