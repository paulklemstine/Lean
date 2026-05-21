def free_monoid_lift(generators, target_assign, target_multiply, target_identity):
    """Free Monoid Synthesis: construct the unique homomorphism."""
    def homomorphism(word):
        if not word:
            return target_identity
        result = target_identity
        for gen in word:
            result = target_multiply(result, target_assign[gen])
        return result
    return homomorphism