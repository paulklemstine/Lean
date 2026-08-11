"""
Numerical demonstrations for the affine Sigma-protocol and zero-knowledge
proofs of provability.

Everything here is exact and finite: the "distributions" are exhaustively
enumerated multisets over small groups, so every claim below is checked by
brute force rather than sampled.

Contents
--------
1.  The Boolean affine protocol over Z/12 with f(x) = 4x.
    - completeness, simulator validity, special soundness (extraction)
    - perfect zero knowledge as an exact multiset identity
    - witness set = coset of ker f  (|W| = |ker f|)
    - view size = |G| for every challenge, true statement or false
2.  Parallel repetition: exhaustive cheat-set enumeration showing a
    witnessless committed prover answers at most one of 2^n challenge vectors.
3.  Unique-witness perfect zero knowledge (f injective): the folklore
    "privacy comes from many witnesses" is refuted numerically.
4.  The Fiat-Shamir inversion: for a TRUE statement every hash admits a
    forgery; for a FALSE statement the image colouring is forgery-free.
5.  Linear protocol over F_q: soundness q^{-n} and extraction by
    w = (c - c')^{-1} (z - z').
6.  OR-composition: the left-knowing and right-knowing provers generate
    identical multisets of conversations.
7.  A toy provability compiler: proofs of a theorem encoded as witnesses.

Run with:  python3 demo.py
"""

from __future__ import annotations

from collections import Counter
from itertools import product
from typing import Callable, Dict, Iterable, List, Optional, Sequence, Tuple

# ----------------------------------------------------------------------------
# Types
# ----------------------------------------------------------------------------

Elem = int                       # element of Z/m, represented as 0..m-1
Transcript = Tuple[int, int, int]  # (commitment, challenge, response)
OrTranscript = Tuple[int, int, int, int, int, int]


# ----------------------------------------------------------------------------
# 1. The Boolean affine protocol over a cyclic group
# ----------------------------------------------------------------------------


class AffineStatement:
    """The public statement 'exists w in Z/m with k*w = target'.

    The homomorphism is f(x) = k*x on Z/m; the challenge selector is
    chi(c, x) = x if c == 1 else 0.
    """

    def __init__(self, modulus: int, k: int, target: int) -> None:
        self.m: int = modulus
        self.k: int = k % modulus
        self.target: int = target % modulus

    # -- basic maps ---------------------------------------------------------

    def f(self, x: Elem) -> Elem:
        return (self.k * x) % self.m

    def chi(self, c: int, x: Elem) -> Elem:
        return x % self.m if c == 1 else 0

    def elements(self) -> List[Elem]:
        return list(range(self.m))

    # -- witnesses ----------------------------------------------------------

    def witnesses(self) -> List[Elem]:
        return [w for w in self.elements() if self.f(w) == self.target]

    def kernel(self) -> List[Elem]:
        return [x for x in self.elements() if self.f(x) == 0]

    def image(self) -> List[Elem]:
        return sorted({self.f(x) for x in self.elements()})

    # -- protocol -----------------------------------------------------------

    def accepts(self, t: Transcript) -> bool:
        a, c, z = t
        return self.f(z) == (a + self.chi(c, self.target)) % self.m

    def real(self, w: Elem, r: Elem, c: int) -> Transcript:
        return (self.f(r), c, (r + self.chi(c, w)) % self.m)

    def sim(self, z: Elem, c: int) -> Transcript:
        return ((self.f(z) - self.chi(c, self.target)) % self.m, c, z)

    def real_view(self, w: Elem, c: int) -> Counter:
        return Counter(self.real(w, r, c) for r in self.elements())

    def sim_view(self, c: int) -> Counter:
        return Counter(self.sim(z, c) for z in self.elements())

    def accepting_set(self, c: int) -> List[Transcript]:
        return [
            (a, c, z)
            for a in self.elements()
            for z in self.elements()
            if self.accepts((a, c, z))
        ]

    @staticmethod
    def extract(z_false: Elem, z_true: Elem, modulus: int) -> Elem:
        """Special soundness: two answers at one commitment give a witness."""
        return (z_true - z_false) % modulus


def demo_boolean_protocol() -> None:
    print("=" * 74)
    print("1. THE BOOLEAN AFFINE PROTOCOL OVER Z/12 WITH f(x) = 4x")
    print("=" * 74)

    true_stmt = AffineStatement(12, 4, 8)    # 4w = 8   -- solvable
    false_stmt = AffineStatement(12, 4, 1)   # 4w = 1   -- unsolvable

    print(f"image of f            : {true_stmt.image()}")
    print(f"witnesses of 4w = 8   : {true_stmt.witnesses()}")
    print(f"kernel of f           : {true_stmt.kernel()}")
    print(f"|W| = |ker f|         : "
          f"{len(true_stmt.witnesses())} = {len(true_stmt.kernel())}  "
          f"{len(true_stmt.witnesses()) == len(true_stmt.kernel())}")
    print(f"witnesses of 4w = 1   : {false_stmt.witnesses()}  (statement false)")

    # completeness
    ok = all(
        true_stmt.accepts(true_stmt.real(w, r, c))
        for w in true_stmt.witnesses()
        for r in true_stmt.elements()
        for c in (0, 1)
    )
    print(f"\ncompleteness (all witnesses, tapes, challenges) : {ok}")

    # simulator validity, for the FALSE statement too
    ok = all(
        false_stmt.accepts(false_stmt.sim(z, c))
        for z in false_stmt.elements()
        for c in (0, 1)
    )
    print(f"simulator valid even for a FALSE statement      : {ok}")

    # extraction
    r = 7
    a = true_stmt.f(r)
    z0, z1 = r, (r + 2) % 12
    assert true_stmt.accepts((a, 0, z0)) and true_stmt.accepts((a, 1, z1))
    w = AffineStatement.extract(z0, z1, 12)
    print(f"extraction at a = 4*{r} = {a}: z1 - z0 = {w}, "
          f"is a witness: {true_stmt.f(w) == true_stmt.target}")

    # perfect zero knowledge as exact multiset identity
    print("\nperfect zero knowledge (exact multiset identities):")
    for c in (0, 1):
        for w in true_stmt.witnesses():
            same = true_stmt.real_view(w, c) == true_stmt.sim_view(c)
            print(f"  challenge {c}, witness {w:2d}: real view == sim view : {same}")

    # witness indistinguishability
    same = true_stmt.real_view(2, 1) == true_stmt.real_view(5, 1)
    print(f"\nwitnesses 2 and 5 give identical views          : {same}")

    # view size
    print("\nview size (Theorem: |accepting set| = |G| always):")
    for name, st in (("true  4w=8", true_stmt), ("false 4w=1", false_stmt)):
        sizes = [len(st.accepting_set(c)) for c in (0, 1)]
        print(f"  {name}: |accepting(c=0)| = {sizes[0]}, "
              f"|accepting(c=1)| = {sizes[1]}   (|G| = 12)")

    # accepting set == range of simulator, for the false statement too
    for st, name in ((true_stmt, "true"), (false_stmt, "false")):
        for c in (0, 1):
            assert set(st.accepting_set(c)) == {st.sim(z, c) for z in st.elements()}
    print("accepting set == range of simulator, both statements, both challenges: True")


# ----------------------------------------------------------------------------
# 2. Parallel repetition and the cheat set
# ----------------------------------------------------------------------------


def cheat_set(
    stmt: AffineStatement,
    commitments: Sequence[int],
    respond: Callable[[Tuple[int, ...]], Tuple[int, ...]],
) -> List[Tuple[int, ...]]:
    """Challenge vectors an already-committed prover can answer."""
    n = len(commitments)
    good: List[Tuple[int, ...]] = []
    for c in product((0, 1), repeat=n):
        z = respond(c)
        if all(stmt.accepts((commitments[i], c[i], z[i])) for i in range(n)):
            good.append(c)
    return good


def best_cheating_prover(
    stmt: AffineStatement, commitments: Sequence[int]
) -> Callable[[Tuple[int, ...]], Tuple[int, ...]]:
    """The optimal (unbounded) adversary: for each challenge vector, answer
    each round with any response that satisfies the verification equation,
    if one exists."""
    n = len(commitments)

    def respond(c: Tuple[int, ...]) -> Tuple[int, ...]:
        out: List[int] = []
        for i in range(n):
            found = 0
            for z in stmt.elements():
                if stmt.accepts((commitments[i], c[i], z)):
                    found = z
                    break
            out.append(found)
        return tuple(out)

    return respond


def demo_parallel_repetition() -> None:
    print()
    print("=" * 74)
    print("2. PARALLEL REPETITION: EXHAUSTIVE CHEAT-SET ENUMERATION")
    print("=" * 74)

    false_stmt = AffineStatement(12, 4, 1)
    true_stmt = AffineStatement(12, 4, 8)

    print("false statement 4w = 1: optimal unbounded prover, all commitment")
    print("vectors enumerated; |cheat set| out of 2^n.\n")
    for n in (1, 2, 3, 4):
        worst = 0
        for commitments in product(range(12), repeat=n):
            cs = cheat_set(false_stmt, commitments, best_cheating_prover(false_stmt, commitments))
            worst = max(worst, len(cs))
        print(f"  n = {n}: max |cheat set| over all commitments = {worst} "
              f"out of {2 ** n}   (bound: 1, fraction <= {1 / 2 ** n:.6f})")

    print("\ntrue statement 4w = 8: honest prover with witness 2, tapes all zero")
    for n in (1, 2, 3, 4):
        commitments = tuple(true_stmt.f(0) for _ in range(n))

        def honest(c: Tuple[int, ...], n: int = n) -> Tuple[int, ...]:
            return tuple(true_stmt.chi(c[i], 2) for i in range(n))

        cs = cheat_set(true_stmt, commitments, honest)
        print(f"  n = {n}: |cheat set| = {len(cs)} out of {2 ** n}  (all of them)")


# ----------------------------------------------------------------------------
# 3. Unique witness, perfect zero knowledge
# ----------------------------------------------------------------------------


def demo_unique_witness() -> None:
    print()
    print("=" * 74)
    print("3. UNIQUE WITNESS, STILL PERFECT ZERO KNOWLEDGE")
    print("=" * 74)

    # f(x) = 5x on Z/12 is injective (gcd(5,12) = 1)
    stmt = AffineStatement(12, 5, 7)
    ws = stmt.witnesses()
    print(f"f(x) = 5x on Z/12, target 7")
    print(f"kernel        : {stmt.kernel()}   (trivial => f injective)")
    print(f"witnesses     : {ws}   (|W| = {len(ws)})")
    for c in (0, 1):
        same = stmt.real_view(ws[0], c) == stmt.sim_view(c)
        print(f"challenge {c}   : real view == sim view : {same}")
    print("\nNo witness ambiguity whatsoever, and yet the view is exactly the")
    print("simulator's: privacy comes from translation symmetry of the tape.")


# ----------------------------------------------------------------------------
# 4. The Fiat-Shamir inversion
# ----------------------------------------------------------------------------


def forgery_exists(stmt: AffineStatement, hash_fn: Callable[[int], int]) -> Optional[Tuple[int, int]]:
    """Return an accepted non-interactive pair (a, z), or None."""
    for z in stmt.elements():
        for c in (0, 1):
            a = (stmt.f(z) - stmt.chi(c, stmt.target)) % stmt.m
            if hash_fn(a) == c:
                return (a, z)
    return None


def all_hashes(m: int) -> Iterable[Callable[[int], int]]:
    """Enumerate every function Z/m -> {0,1}.  Only feasible for tiny m."""
    for bits in product((0, 1), repeat=m):
        yield (lambda a, bits=bits: bits[a % m])


def demo_fiat_shamir() -> None:
    print()
    print("=" * 74)
    print("4. THE FIAT-SHAMIR INVERSION")
    print("=" * 74)

    # small group so that all 2^m hash functions can be enumerated
    true_small = AffineStatement(6, 2, 4)    # 2w = 4 mod 6 : witnesses 2, 5
    false_small = AffineStatement(6, 2, 1)   # 2w = 1 mod 6 : none

    print(f"group Z/6, f(x) = 2x; image = {true_small.image()}")
    print(f"true  statement 2w = 4: witnesses {true_small.witnesses()}")
    print(f"false statement 2w = 1: witnesses {false_small.witnesses()}")

    total = 2 ** 6
    forgeable_true = sum(1 for h in all_hashes(6) if forgery_exists(true_small, h))
    forgeable_false = sum(1 for h in all_hashes(6) if forgery_exists(false_small, h))
    print(f"\nhash functions Z/6 -> {{0,1}} enumerated: {total}")
    print(f"  TRUE  statement: hashes admitting a forgery = {forgeable_true} / {total}")
    print(f"  FALSE statement: hashes admitting a forgery = {forgeable_false} / {total}")
    print(f"  => forgery-free hashes exist iff the statement is FALSE: "
          f"{forgeable_true == total and forgeable_false < total}")

    # the canonical forgery-free hash on the false statement
    image = set(false_small.image())
    image_hash: Callable[[int], int] = lambda a: 1 if a % 6 in image else 0
    print(f"\nimage colouring on the false statement is forgery-free : "
          f"{forgery_exists(false_small, image_hash) is None}")
    print(f"image colouring on the true  statement is forgeable     : "
          f"{forgery_exists(true_small, image_hash) is not None}")


# ----------------------------------------------------------------------------
# 5. The linear protocol over F_q
# ----------------------------------------------------------------------------


class LinearStatement:
    """f(x) = k*x on F_q (q prime), target T; challenges range over F_q."""

    def __init__(self, q: int, k: int, target: int) -> None:
        self.q: int = q
        self.k: int = k % q
        self.target: int = target % q

    def f(self, x: int) -> int:
        return (self.k * x) % self.q

    def elements(self) -> List[int]:
        return list(range(self.q))

    def witnesses(self) -> List[int]:
        return [w for w in self.elements() if self.f(w) == self.target]

    def accepts(self, a: int, c: int, z: int) -> bool:
        return self.f(z) == (a + c * self.target) % self.q

    def real(self, w: int, r: int, c: int) -> Tuple[int, int, int]:
        return (self.f(r), c, (r + c * w) % self.q)

    def sim(self, z: int, c: int) -> Tuple[int, int, int]:
        return ((self.f(z) - c * self.target) % self.q, c, z)

    def extract(self, c: int, z: int, c2: int, z2: int) -> int:
        """w = (c - c')^{-1} (z - z') in F_q."""
        diff = (c - c2) % self.q
        inv = pow(diff, self.q - 2, self.q)  # Fermat inverse, q prime
        return (inv * (z - z2)) % self.q


def demo_linear() -> None:
    print()
    print("=" * 74)
    print("5. LINEAR PROTOCOL OVER F_q: SOUNDNESS q^{-n} AND LINEAR EXTRACTION")
    print("=" * 74)

    q = 5
    id_stmt = LinearStatement(q, 1, 3)     # w = 3, unique witness
    zero_stmt = LinearStatement(q, 0, 1)   # no witness

    print(f"F_5, identity map, target 3 : witnesses {id_stmt.witnesses()}")
    print(f"F_5, zero map,     target 1 : witnesses {zero_stmt.witnesses()}")

    # perfect zero knowledge over every challenge in F_q
    ok = all(
        Counter(id_stmt.real(3, r, c) for r in id_stmt.elements())
        == Counter(id_stmt.sim(z, c) for z in id_stmt.elements())
        for c in range(q)
    )
    print(f"perfect zero knowledge for every challenge in F_5 : {ok}")

    # linear extraction from two distinct challenges
    r = 4
    a = id_stmt.f(r)
    c, c2 = 1, 4
    z = (r + c * 3) % q
    z2 = (r + c2 * 3) % q
    assert id_stmt.accepts(a, c, z) and id_stmt.accepts(a, c2, z2)
    print(f"extraction from challenges {c} and {c2}: "
          f"(c-c')^-1 (z-z') = {id_stmt.extract(c, z, c2, z2)}  (witness is 3)")

    # exhaustive soundness for the false statement
    print("\nfalse statement, optimal unbounded prover, all commitments:")
    for n in (1, 2):
        worst = 0
        for commitments in product(range(q), repeat=n):
            good = 0
            for cs in product(range(q), repeat=n):
                answerable = True
                for i in range(n):
                    if not any(zero_stmt.accepts(commitments[i], cs[i], z)
                               for z in zero_stmt.elements()):
                        answerable = False
                        break
                good += 1 if answerable else 0
            worst = max(worst, good)
        print(f"  n = {n}: max |cheat set| = {worst} out of {q ** n} "
              f"(bound 1, fraction <= {1 / q ** n:.6f})")


# ----------------------------------------------------------------------------
# 6. OR-composition
# ----------------------------------------------------------------------------


def or_left(
    s1: AffineStatement, s2: AffineStatement, w1: int, c: int, r: int, z: int, d: int
) -> OrTranscript:
    m = s1.m
    return (
        s1.f(r),
        (s2.f(z) - s2.chi(d, s2.target)) % m,
        c ^ d,
        d,
        (r + s1.chi(c ^ d, w1)) % m,
        z,
    )


def or_right(
    s1: AffineStatement, s2: AffineStatement, w2: int, c: int, r: int, z: int, d: int
) -> OrTranscript:
    m = s1.m
    return (
        (s1.f(z) - s1.chi(d, s1.target)) % m,
        s2.f(r),
        d,
        c ^ d,
        z,
        (r + s2.chi(c ^ d, w2)) % m,
    )


def or_accepts(s1: AffineStatement, s2: AffineStatement, c: int, t: OrTranscript) -> bool:
    a1, a2, c1, c2, z1, z2 = t
    return (c1 ^ c2) == c and s1.accepts((a1, c1, z1)) and s2.accepts((a2, c2, z2))


def demo_or_composition() -> None:
    print()
    print("=" * 74)
    print("6. OR-COMPOSITION: WHICH-THEOREM HIDING")
    print("=" * 74)

    s1 = AffineStatement(6, 2, 4)   # witnesses 2, 5
    s2 = AffineStatement(6, 3, 3)   # witnesses 1, 3, 5
    w1, w2 = s1.witnesses()[0], s2.witnesses()[0]
    print(f"s1: 2w = 4 mod 6, witnesses {s1.witnesses()} (using {w1})")
    print(f"s2: 3w = 3 mod 6, witnesses {s2.witnesses()} (using {w2})")

    rand = [(r, z, d) for r in range(6) for z in range(6) for d in (0, 1)]
    for c in (0, 1):
        left = Counter(or_left(s1, s2, w1, c, r, z, d) for (r, z, d) in rand)
        right = Counter(or_right(s1, s2, w2, c, r, z, d) for (r, z, d) in rand)
        complete = all(or_accepts(s1, s2, c, t) for t in left)
        print(f"challenge {c}: left view == right view : {left == right}   "
              f"(all accepted: {complete}, {sum(left.values())} conversations)")

    print("\nThe verifier cannot tell which of the two statements the prover")
    print("is able to prove: the two strategies induce the same distribution.")

    # disjunctive soundness, illustrated
    r, z, d = 1, 2, 0
    t0 = or_left(s1, s2, w1, 0, r, z, d)
    t1 = or_left(s1, s2, w1, 1, r, z, d)
    shares = (t0[0], t0[1]) == (t1[0], t1[1])
    print(f"\ntwo conversations, same commitments {shares}, challenges 0 and 1")
    print(f"  => sub-challenges differ somewhere: "
          f"{(t0[2] != t1[2]) or (t0[3] != t1[3])} => a witness is extractable")


# ----------------------------------------------------------------------------
# 7. A toy provability compiler
# ----------------------------------------------------------------------------


def demo_provability_compiler() -> None:
    print()
    print("=" * 74)
    print("7. A TOY PROVABILITY COMPILER")
    print("=" * 74)

    # Formal system: "proofs" are strings; a proof checks the theorem
    # THM iff it is one of two admissible derivations.  The encoding sends
    # both to witnesses of the public statement 4w = 8 mod 12.
    checking_proofs: Dict[str, int] = {"short derivation": 2, "long derivation": 5}
    stmt = AffineStatement(12, 4, 8)

    print("theorem THM has two checking proofs, encoded as group elements:")
    for p, e in checking_proofs.items():
        print(f"  {p!r:20s} -> {e:2d}   is a witness: {stmt.f(e) == stmt.target}")

    print("\n(i) identical views for the two proofs, each challenge:")
    for c in (0, 1):
        v = [stmt.real_view(e, c) for e in checking_proofs.values()]
        print(f"  challenge {c}: views equal = {v[0] == v[1]}, "
              f"equal to simulator = {v[0] == stmt.sim_view(c)}")

    print("\n(ii) conviction: a double answer certifies provability.")
    r = 3
    a = stmt.f(r)
    z0, z1 = r, (r + 2) % 12
    w = AffineStatement.extract(z0, z1, 12)
    provable = stmt.f(w) == stmt.target
    print(f"  extracted {w}; statement true => THM provable : {provable}")

    print("\n(iii) an UNPROVABLE theorem compiles to 4w = 1, which has no")
    print("      witness; over n rounds a committed prover survives with")
    print("      probability at most 2^-n:")
    unprov = AffineStatement(12, 4, 1)
    for n in (1, 4, 10, 128):
        print(f"      n = {n:3d}: bound = 2^-{n} = {2.0 ** (-n):.3e}")
    print(f"      witnesses of the compiled statement: {unprov.witnesses()}")

    print("\n(iv) BOUNDARY: with the zero homomorphism every element is a")
    print("     witness, so the compilation certifies nothing at all.")
    vacuous = AffineStatement(12, 0, 0)
    print(f"     f = 0, target 0: |witnesses| = {len(vacuous.witnesses())} "
          f"= |G| = 12  -> vacuous")


# ----------------------------------------------------------------------------


def main() -> None:
    demo_boolean_protocol()
    demo_parallel_repetition()
    demo_unique_witness()
    demo_fiat_shamir()
    demo_linear()
    demo_or_composition()
    demo_provability_compiler()
    print()
    print("=" * 74)
    print("All demonstrations completed.")
    print("=" * 74)


if __name__ == "__main__":
    main()
