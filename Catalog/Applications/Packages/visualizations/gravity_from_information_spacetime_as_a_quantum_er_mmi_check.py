def check_mmi(S, n):
    violations = []
    for A,B,C in all_triples(n):
        I3 = S[A]+S[B]+S[C]-S[A|B]-S[A|C]-S[B|C]+S[A|B|C]
        if I3 > 0: violations.append((A,B,C,I3))
    return violations