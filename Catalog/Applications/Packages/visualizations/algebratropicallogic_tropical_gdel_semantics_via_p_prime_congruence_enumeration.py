def enumerate_prime_congruences(elements, add_op, mul_op):
    """Find all prime congruences on a finite idempotent semiring."""
    from itertools import product
    
    def partitions(s):
        if len(s) <= 1:
            yield [set(s)]
            return
        first = s[0]
        rest = s[1:]
        for p in partitions(rest):
            yield [set([first])] + p
            for i, block in enumerate(p):
                new_p = [b.copy() for b in p]
                new_p[i].add(first)
                yield new_p
    
    def same_class(partition, a, b):
        for cls in partition:
            if a in cls and b in cls:
                return True
        return False
    
    results = []
    for partition in partitions(list(elements)):
        # Check congruence
        is_cong = True
        for a, b, c, d in product(elements, repeat=4):
            if same_class(partition, a, c) and same_class(partition, b, d):
                if not same_class(partition, add_op(a,b), add_op(c,d)):
                    is_cong = False; break
                if not same_class(partition, mul_op(a,b), mul_op(c,d)):
                    is_cong = False; break
        if not is_cong:
            continue
        # Check primality
        is_prime = True
        for a, b in product(elements, repeat=2):
            m = add_op(a, b)
            if not (same_class(partition, m, a) or same_class(partition, m, b)):
                is_prime = False; break
        if is_prime:
            results.append(partition)
    return results
