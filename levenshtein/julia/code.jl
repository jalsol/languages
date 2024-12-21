# Calculates the Levenshtein distance between two strings using Wagner-Fischer algorithm
# Space Complexity: O(min(m,n)) - only uses two arrays instead of full matrix
# Time Complexity: O(m*n) where m and n are the lengths of the input strings
function levenshtein_distance(s1::String, s2::String)::Int
    # Early termination checks
    s1 == s2 && return 0
    isempty(s1) && return length(s2)
    isempty(s2) && return length(s1)

    # Make s1 the shorter string for space optimization
    if length(s1) > length(s2)
        s1, s2 = s2, s1
    end

    m, n = length(s1), length(s2)

    # Use two arrays instead of full matrix for space optimization
    prev_row = Vector{Int}(undef, m + 1)
    curr_row = Vector{Int}(undef, m + 1)

    # Initialize first row
    @simd for i in 0:m
        @inbounds prev_row[i + 1] = i
    end

    # Main computation loop
    @inbounds for j in 1:n
        curr_row[1] = j

        @simd for i in 1:m
            cost = s1[i] == s2[j] ? 0 : 1
            
            # Calculate minimum of three operations
            @inbounds curr_row[i + 1] = min(
                prev_row[i + 1] + 1,    # deletion
                curr_row[i] + 1,        # insertion
                prev_row[i] + cost      # substitution
            )
        end

        # Swap rows
        prev_row, curr_row = curr_row, prev_row
    end

    return prev_row[m + 1]
end

function main()
    if length(ARGS) < 2
        println("Please provide at least two strings as arguments.")
        exit(1)
    end

    min_distance = -1
    times = 0

    # Compare all pairs of strings
    for i in 1:length(ARGS)
        for j in 1:length(ARGS)
            if i != j
                distance = levenshtein_distance(ARGS[i], ARGS[j])
                if min_distance == -1 || distance < min_distance
                    min_distance = distance
                end
                times += 1
            end
        end
    end

    println("times: ", times)
    println("min_distance: ", min_distance)
end

# Run main only if script is run directly
if abspath(PROGRAM_FILE) == @__FILE__
    main()
end
