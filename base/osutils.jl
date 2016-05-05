# This file is a part of Julia. License is MIT: http://julialang.org/license

"""
    is_unix([os])

Predicate for testing if the OS provides a Unix-like interface.
See documentation :ref:`Handling Operating System Variation <man-handling-operating-system-variation>`\ .
"""
function is_unix(os::Symbol)
    if is_windows(os)
        return false
    elseif is_linux(os) || is_bsd(os)
        return true
    else
        throw(ArgumentError("unknown operating system \"$os\""))
    end
end

"""
    is_linux([os])

Predicate for testing if the OS is a derivative of Linux.
See documentation :ref:`Handling Operating System Variation <man-handling-operating-system-variation>`\ .
"""
is_linux(os::Symbol) = (os == :Linux)

"""
    is_bsd([os])

Predicate for testing if the OS is a derivative of BSD.
See documentation :ref:`Handling Operating System Variation <man-handling-operating-system-variation>`\ .
"""
is_bsd(os::Symbol) = (os == :FreeBSD || os == :OpenBSD || os == :NetBSD || os == :Darwin || os == :Apple)

"""
    is_windows([os])

Predicate for testing if the OS is a derivative of Microsoft Windows NT.
See documentation :ref:`Handling Operating System Variation <man-handling-operating-system-variation>`\ .
"""
is_windows(os::Symbol) = (os == :Windows || os == :NT)

"""
    is_apple([os])

Predicate for testing if the OS is a derivative of Apple Macintosh OS X or Darwin.
See documentation :ref:`Handling Operating System Variation <man-handling-operating-system-variation>`\ .
"""
is_apple(os::Symbol) = (os == :Apple || os == :Darwin)

"""
    @static

Partially evaluates an expression at parse time.

For example, `@static is_windows() ? foo : bar` will evaluate `is_windows()` and insert either `foo` or `bar` into the expression.
This is useful in cases where a construct would be invalid on other platforms,
such as a ccall to a non-existent functions.
"""
macro static(ex)
    if isa(ex, Expr)
        if ex.head === :if
            cond = eval(current_module(), ex.args[1])
            if cond
                return esc(ex.args[2])
            elseif length(ex.args) == 3
                return esc(ex.args[3])
            else
                return nothing
            end
        end
    end
    throw(ArgumentError("invalid @static macro"))
end

let KERNEL = ccall(:jl_get_UNAME, Any, ())
    # evaluate the zero-argument form of each of these functions
    # as a function returning a static constant based on the build-time
    # operating-system kernel
    for f in (:is_unix, :is_linux, :is_bsd, :is_apple, :is_windows)
        @eval $f() = $(getfield(current_module(),f)(KERNEL))
    end
end
