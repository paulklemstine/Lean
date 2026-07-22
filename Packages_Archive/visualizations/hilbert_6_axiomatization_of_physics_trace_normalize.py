from typing import List, Union
# Trace expressions are tagged tuples; signed atoms are (direction, name).
SignedAtom = tuple        # ("fwd"|"bwd", name)
TraceWord = List[SignedAtom]
TraceNormalForm = List[TraceWord]

def flip(s: SignedAtom) -> SignedAtom:
    d, name = s
    return ("bwd" if d == "fwd" else "fwd", name)

def rev_word(w: TraceWord) -> TraceWord:
    # reverse order AND flip each atom: discrete form of (a*b)^T = b^T a^T
    return [flip(s) for s in reversed(w)]

def rev_nf(nf: TraceNormalForm) -> TraceNormalForm:
    return [rev_word(w) for w in nf]

def mul_nf(n1: TraceNormalForm, n2: TraceNormalForm) -> TraceNormalForm:
    # distribute a sum of words against a sum of words
    return [w1 + w2 for w1 in n1 for w2 in n2]

def normalize(e) -> TraceNormalForm:
    """Normalize a trace expression into a sum of words of signed atoms.

    e is one of:
      ("zero",) ("one",) ("atom", name) ("add", l, r) ("mul", l, r) ("rev", x)
    """
    tag = e[0]
    if tag == "zero":
        return []
    if tag == "one":
        return [[]]
    if tag == "atom":
        return [[("fwd", e[1])]]
    if tag == "add":
        return normalize(e[1]) + normalize(e[2])
    if tag == "mul":
        return mul_nf(normalize(e[1]), normalize(e[2]))
    if tag == "rev":
        return rev_nf(normalize(e[1]))
    raise ValueError(f"unknown node {tag}")
