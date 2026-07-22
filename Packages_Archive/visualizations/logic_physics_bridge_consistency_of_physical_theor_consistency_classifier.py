def classify_consistency(sentences, worlds, theory, provable, satisfies, falsum=0):
    """Classify a theory as inconsistent, math-only-consistent, or physically consistent."""
    # Step 1: Check mathematical consistency
    math_consistent = not provable(falsum)
    if not math_consistent:
        return "inconsistent"
    # Step 2: Check physical consistency
    for w in range(len(worlds)):
        if all(satisfies(w, s) for s in theory):
            return "physically_consistent"
    return "mathematically_consistent_only"

# Example usage
print(classify_consistency(["⊥","p"], [], set(), lambda s: False, lambda w,s: False))
# Output: mathematically_consistent_only