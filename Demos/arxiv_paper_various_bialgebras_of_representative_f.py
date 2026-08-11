"""
Various Bialgebras of Representative Functions on Free Monoids
==============================================================

Self-contained numerical demonstrations of the results of the accompanying
paper.  Everything is computed exactly (integers and rationals); no external
libraries beyond the Python standard library are used.

The objects.  Let X be a finite alphabet and X* the free monoid of words.
On the vector space K<X> spanned by words we study two dual bialgebra
structures:

    (K<X>, concatenation, Delta_shuffle)   graded, noncommutative, cocommutative
    (K<X>, shuffle,       Delta_deconcat)  graded, commutative,   co-noncommutative

and the "series" side K<<X>> = functions f : X* -> K, where the pairing
<f, w> = f(w) makes shuffle and unshuffle adjoint.

The demonstrations below verify, on explicit data:

  1. the shuffle product of words: commutativity, associativity, and the
     binomial cardinality |u shuffle v| = C(|u|+|v|, |u|);
  2. shuffle/unshuffle duality: <u shuffle v, w> = <u tensor v, Delta_sh(w)>;
  3. the bialgebra axiom Delta_sh(uv) = Delta_sh(u) Delta_sh(v), plus
     coassociativity and cocommutativity of Delta_sh;
  4. the bialgebra axiom Delta_dec(u shuffle v) = Delta_dec(u) shuffle_2
     Delta_dec(v) for the deconcatenation coproduct;
  5. characters: Kleene stars of planes are exactly the concatenation
     characters; exponentials of planes are shuffle characters, with the
     divided-power values f(a^n) = f(a)^n / n!;
  6. Kleene-Schuetzenberger: a function is representative iff it has a finite
     dimensional space of left translates iff it has a linear representation;
  7. rationality is stable under the shuffle product of series;
  8. the separation theorem: exp(l) is a shuffle character of infinite Hankel
     rank, hence not representative, while the Kleene star l* is representative
     of rank one but is not a shuffle character unless l = 0.
"""

from __future__ import annotations

from collections import Counter
from fractions import Fraction
from itertools import product
from math import comb, factorial
from typing import Callable, Dict, Iterable, List, Tuple

Word = Tuple[str, ...]
Pair = Tuple[Word, Word]


# ----------------------------------------------------------------------------
# 1. Words, shuffle product, coproducts
# ----------------------------------------------------------------------------

def w(s: str) -> Word:
    """Turn the string 's' into a word (a tuple of one-letter symbols)."""
    return tuple(s)


def show(word: Word) -> str:
    """Render a word; the empty word is printed as '1'."""
    return "".join(word) if word else "1"


def shuffle(u: Word, v: Word) -> Counter:
    """The multiset u shuffle v of all interleavings of u and v, with
    multiplicity, computed by the classical recursion

        1 shuffle v = v,  u shuffle 1 = u,
        au shuffle bv = a (u shuffle bv) + b (au shuffle v).

    The result has C(|u|+|v|, |u|) elements counted with multiplicity."""
    if not u:
        return Counter({v: 1})
    if not v:
        return Counter({u: 1})
    out: Counter = Counter()
    for z, m in shuffle(u[1:], v).items():
        out[(u[0],) + z] += m
    for z, m in shuffle(u, v[1:]).items():
        out[(v[0],) + z] += m
    return out


def unshuffle(word: Word) -> Counter:
    """The unshuffle coproduct Delta_sh(w) = sum over splittings of the
    positions of w into two complementary subsequences, given by the recursion
    Delta_sh(aw) = (a tensor 1 + 1 tensor a) . Delta_sh(w).  It has exactly
    2^|w| terms with multiplicity."""
    if not word:
        return Counter({((), ()): 1})
    a, rest = word[0], word[1:]
    out: Counter = Counter()
    for (p, q), m in unshuffle(rest).items():
        out[((a,) + p, q)] += m
        out[(p, (a,) + q)] += m
    return out


def deconcat(word: Word) -> Counter:
    """The deconcatenation coproduct Delta_dec(w) = sum_{w = z1 z2} z1 tensor z2.
    It has exactly |w| + 1 terms, each with multiplicity one."""
    return Counter({(word[:k], word[k:]): 1 for k in range(len(word) + 1)})


def pair_mul(s: Counter, t: Counter) -> Counter:
    """Componentwise concatenation of tensors: the product of the tensor square
    for the concatenation product."""
    out: Counter = Counter()
    for (p1, p2), m in s.items():
        for (q1, q2), n in t.items():
            out[(p1 + q1, p2 + q2)] += m * n
    return out


def shuffle_pair(p: Pair, q: Pair) -> Counter:
    """Shuffle product of two elementary tensors: (p1 tensor p2) shuffle_2
    (q1 tensor q2) = (p1 shuffle q1) tensor (p2 shuffle q2)."""
    out: Counter = Counter()
    for r, m in shuffle(p[0], q[0]).items():
        for s, n in shuffle(p[1], q[1]).items():
            out[(r, s)] += m * n
    return out


def bind_deconcat(s: Counter) -> Counter:
    """Apply Delta_dec linearly to a multiset of words."""
    out: Counter = Counter()
    for z, m in s.items():
        for pr, n in deconcat(z).items():
            out[pr] += m * n
    return out


def deconc_shuffle_prod(u: Word, v: Word) -> Counter:
    """Delta_dec(u) shuffle_2 Delta_dec(v)."""
    out: Counter = Counter()
    for p, m in deconcat(u).items():
        for q, n in deconcat(v).items():
            for pr, k in shuffle_pair(p, q).items():
                out[pr] += m * n * k
    return out


def all_words(alphabet: str, max_len: int) -> List[Word]:
    """All words over 'alphabet' of length at most 'max_len', in shortlex order."""
    out: List[Word] = []
    for n in range(max_len + 1):
        out.extend(product(tuple(alphabet), repeat=n))
    return out


# ----------------------------------------------------------------------------
# 2. Series, shuffle of series, characters
# ----------------------------------------------------------------------------

Series = Callable[[Word], Fraction]


def shuffle_series(f: Series, g: Series) -> Series:
    """The shuffle product of two series, defined coefficientwise through the
    unshuffle coproduct:  (f shuffle g)(w) = sum_{(u,v) in Delta_sh(w)} f(u)g(v)."""
    def h(word: Word) -> Fraction:
        return sum((Fraction(m) * f(p) * g(q) for (p, q), m in unshuffle(word).items()),
                   Fraction(0))
    return h


def counit(word: Word) -> Fraction:
    """The counit: 1 on the empty word, 0 elsewhere; unit for the shuffle
    product of series."""
    return Fraction(1) if not word else Fraction(0)


def plane_star(c: Dict[str, Fraction]) -> Series:
    """The Kleene star l* of the plane l = sum_x c_x x: the monoid morphism
    w = x1...xn  |->  c_{x1} ... c_{xn}.  These are exactly the characters of
    the concatenation bialgebra."""
    def f(word: Word) -> Fraction:
        out = Fraction(1)
        for a in word:
            out *= c[a]
        return out
    return f


def exp_plane(c: Dict[str, Fraction]) -> Series:
    """The exponential exp(l) of the plane l = sum_x c_x x: the series whose
    coefficient at a word of length n is c_{x1}...c_{xn} / n!.  These are
    characters of the shuffle algebra (group-like for Delta_sh)."""
    def f(word: Word) -> Fraction:
        out = Fraction(1)
        for a in word:
            out *= c[a]
        return out / factorial(len(word))
    return f


def is_concat_character(f: Series, words: Iterable[Word]) -> bool:
    """Test f(1) = 1 and f(uv) = f(u) f(v) on the supplied words."""
    if f(()) != 1:
        return False
    return all(f(u + v) == f(u) * f(v) for u in words for v in words)


def is_shuffle_character(f: Series, words: Iterable[Word]) -> bool:
    """Test f(1) = 1 and f(u) f(v) = sum_{z in u shuffle v} f(z)."""
    if f(()) != 1:
        return False
    for u in words:
        for v in words:
            rhs = sum((Fraction(m) * f(z) for z, m in shuffle(u, v).items()), Fraction(0))
            if f(u) * f(v) != rhs:
                return False
    return True


# ----------------------------------------------------------------------------
# 3. Representative functions: Hankel rank and linear representations
# ----------------------------------------------------------------------------

def rank(matrix: List[List[Fraction]]) -> int:
    """Exact rank of a rational matrix by Gaussian elimination."""
    m = [row[:] for row in matrix]
    rows, cols = len(m), (len(m[0]) if m else 0)
    r = 0
    for c in range(cols):
        piv = next((i for i in range(r, rows) if m[i][c] != 0), None)
        if piv is None:
            continue
        m[r], m[piv] = m[piv], m[r]
        pivot = m[r][c]
        m[r] = [x / pivot for x in m[r]]
        for i in range(rows):
            if i != r and m[i][c] != 0:
                factor = m[i][c]
                m[i] = [x - factor * y for x, y in zip(m[i], m[r])]
        r += 1
        if r == rows:
            break
    return r


def hankel_rank(f: Series, alphabet: str, depth: int) -> int:
    """Rank of the truncated Hankel matrix [ f(uv) ]_{|u|,|v| <= depth}.  By the
    Kleene-Schuetzenberger theorem, f is representative exactly when these ranks
    stay bounded as depth grows, and the limiting rank is the minimal dimension
    of a linear representation of f."""
    rows = all_words(alphabet, depth)
    cols = all_words(alphabet, depth)
    return rank([[f(u + v) for v in cols] for u in rows])


def determinant(matrix: List[List[Fraction]]) -> Fraction:
    """Exact determinant by fraction-free-style Gaussian elimination."""
    m = [row[:] for row in matrix]
    n = len(m)
    det = Fraction(1)
    for c in range(n):
        piv = next((i for i in range(c, n) if m[i][c] != 0), None)
        if piv is None:
            return Fraction(0)
        if piv != c:
            m[c], m[piv] = m[piv], m[c]
            det = -det
        det *= m[c][c]
        inv = m[c][c]
        m[c] = [x / inv for x in m[c]]
        for i in range(c + 1, n):
            if m[i][c] != 0:
                factor = m[i][c]
                m[i] = [x - factor * y for x, y in zip(m[i], m[c])]
    return det


def matrix_mul(a: List[List[Fraction]], b: List[List[Fraction]]) -> List[List[Fraction]]:
    n, k, p = len(a), len(b), len(b[0])
    return [[sum((a[i][t] * b[t][j] for t in range(k)), Fraction(0)) for j in range(p)]
            for i in range(n)]


def word_matrix(mu: Dict[str, List[List[Fraction]]], word: Word, dim: int) -> List[List[Fraction]]:
    """The multiplicative extension mu : X* -> M_n(K) of a map on letters."""
    out = [[Fraction(1) if i == j else Fraction(0) for j in range(dim)] for i in range(dim)]
    for a in word:
        out = matrix_mul(out, mu[a])
    return out


def linear_rep_series(lam: List[Fraction], mu: Dict[str, List[List[Fraction]]],
                      gam: List[Fraction]) -> Series:
    """The series w |-> lambda mu(w) gamma attached to a linear representation."""
    dim = len(lam)

    def f(word: Word) -> Fraction:
        m = word_matrix(mu, word, dim)
        return sum((lam[i] * m[i][j] * gam[j] for i in range(dim) for j in range(dim)),
                   Fraction(0))
    return f


# ----------------------------------------------------------------------------
# Demonstrations
# ----------------------------------------------------------------------------

def demo_shuffle_basics() -> None:
    print("=" * 76)
    print("1. The shuffle product of words")
    print("=" * 76)
    u, v = w("ab"), w("c")
    print(f"  {show(u)} shuffle {show(v)} = "
          + " + ".join(f"{m}·{show(z)}" for z, m in sorted(shuffle(u, v).items())))
    u, v = w("a"), w("a")
    print(f"  {show(u)} shuffle {show(v)} = "
          + " + ".join(f"{m}·{show(z)}" for z, m in sorted(shuffle(u, v).items()))
          + "     (multiplicity 2: the shuffle is a *multiset*)")

    print("\n  Cardinality |u shuffle v| = C(|u|+|v|, |u|):")
    ok = True
    for u in all_words("ab", 3):
        for v in all_words("ab", 3):
            card = sum(shuffle(u, v).values())
            expected = comb(len(u) + len(v), len(u))
            ok &= (card == expected)
    print(f"    verified for all |u|,|v| <= 3 over {{a,b}}: {ok}")

    print("\n  Commutativity and associativity:")
    words = all_words("ab", 2)
    comm = all(shuffle(u, v) == shuffle(v, u) for u in words for v in words)

    def shuffle3_left(u: Word, x: Word, y: Word) -> Counter:
        out: Counter = Counter()
        for z, m in shuffle(u, x).items():
            for t, n in shuffle(z, y).items():
                out[t] += m * n
        return out

    def shuffle3_right(u: Word, x: Word, y: Word) -> Counter:
        out: Counter = Counter()
        for z, m in shuffle(x, y).items():
            for t, n in shuffle(u, z).items():
                out[t] += m * n
        return out

    assoc = all(shuffle3_left(a, b, c) == shuffle3_right(a, b, c)
                for a in words for b in words for c in words)
    print(f"    u shuffle v = v shuffle u                : {comm}")
    print(f"    (u shuffle v) shuffle t = u shuffle (v shuffle t) : {assoc}")


def demo_duality() -> None:
    print()
    print("=" * 76)
    print("2. Shuffle/unshuffle duality and the two bialgebra axioms")
    print("=" * 76)
    word = w("aba")
    print(f"  Delta_sh({show(word)}) = "
          + " + ".join(f"{m}·({show(p)} ⊗ {show(q)})"
                       for (p, q), m in sorted(unshuffle(word).items())))
    print(f"  it has 2^{len(word)} = {sum(unshuffle(word).values())} terms.")

    words = all_words("ab", 3)
    dual = True
    for u in all_words("ab", 2):
        for v in all_words("ab", 2):
            sh = shuffle(u, v)
            for z in words:
                if sh[z] != unshuffle(z)[(u, v)]:
                    dual = False
    print(f"\n  Duality  <u shuffle v, z> = <u ⊗ v, Delta_sh(z)>  : {dual}")

    bialg = all(unshuffle(u + v) == pair_mul(unshuffle(u), unshuffle(v))
                for u in all_words("ab", 2) for v in all_words("ab", 2))
    print(f"  Bialgebra axiom  Delta_sh(uv) = Delta_sh(u)·Delta_sh(v) : {bialg}")

    cocomm = all(Counter({(q, p): m for (p, q), m in unshuffle(z).items()}) == unshuffle(z)
                 for z in words)
    print(f"  Cocommutativity of Delta_sh                             : {cocomm}")

    def co_left(z: Word) -> Counter:
        out: Counter = Counter()
        for (p, q), m in unshuffle(z).items():
            for (p1, p2), n in unshuffle(p).items():
                out[(p1, p2, q)] += m * n
        return out

    def co_right(z: Word) -> Counter:
        out: Counter = Counter()
        for (p, q), m in unshuffle(z).items():
            for (q1, q2), n in unshuffle(q).items():
                out[(p, q1, q2)] += m * n
        return out

    coassoc = all(co_left(z) == co_right(z) for z in words)
    print(f"  Coassociativity of Delta_sh                             : {coassoc}")

    print("\n  The dual bialgebra (shuffle, deconcatenation):")
    word = w("abc")
    print(f"    Delta_dec({show(word)}) = "
          + " + ".join(f"({show(p)} ⊗ {show(q)})"
                       for (p, q), _ in sorted(deconcat(word).items())))
    axiom = all(bind_deconcat(shuffle(u, v)) == deconc_shuffle_prod(u, v)
                for u in all_words("ab", 2) for v in all_words("ab", 2))
    print("    Bialgebra axiom  Delta_dec(u shuffle v) = "
          f"Delta_dec(u) shuffle_2 Delta_dec(v) : {axiom}")


def demo_characters() -> None:
    print()
    print("=" * 76)
    print("3. Characters: Kleene stars of planes vs. exponentials of planes")
    print("=" * 76)
    c = {"a": Fraction(2), "b": Fraction(-3)}
    words = all_words("ab", 3)
    ps, ep = plane_star(c), exp_plane(c)
    print(f"  plane l = 2a - 3b")
    print(f"    l*   : (l*|ab)   = {ps(w('ab'))},  (l*|aab) = {ps(w('aab'))}")
    print(f"    e^l  : (e^l|ab)  = {ep(w('ab'))},  (e^l|aab) = {ep(w('aab'))}")
    print(f"    l* is a concatenation character : {is_concat_character(ps, words)}")
    print(f"    e^l is a shuffle character      : {is_shuffle_character(ep, all_words('ab', 2))}")
    print(f"    l* is a shuffle character       : "
          f"{is_shuffle_character(ps, all_words('ab', 2))}   (only if l = 0)")

    print("\n  Divided powers: any shuffle character satisfies f(a^n) = f(a)^n / n!")
    for n in range(6):
        lhs = ep((("a",) * n))
        rhs = ep(w("a")) ** n / factorial(n)
        print(f"    n = {n}:  f(a^{n}) = {lhs}   f(a)^{n}/{n}! = {rhs}   equal: {lhs == rhs}")

    print("\n  Infinitesimal characters of the concatenation bialgebra are the planes:")
    g = {(): Fraction(0), ("a",): Fraction(5), ("b",): Fraction(7)}

    def plane(word: Word) -> Fraction:
        return g.get(word, Fraction(0))

    ok = all(plane(u + v) == plane(u) * counit(v) + counit(u) * plane(v)
             for u in words for v in words)
    print(f"    g = 5a + 7b is a derivation for concatenation: {ok}")

    def not_plane(word: Word) -> Fraction:
        return Fraction(1) if word == w("ab") else Fraction(0)

    bad = [(u, v) for u in words for v in words
           if not_plane(u + v) != not_plane(u) * counit(v) + counit(u) * not_plane(v)]
    print(f"    g = ab (length 2) fails, first witness (u,v) = "
          f"({show(bad[0][0])}, {show(bad[0][1])})")


def demo_representative() -> None:
    print()
    print("=" * 76)
    print("4. Representative functions and the Kleene-Schuetzenberger theorem")
    print("=" * 76)
    # f(w) = number of occurrences of the letter 'a': a rank-2 rational series.
    lam = [Fraction(1), Fraction(0)]
    gam = [Fraction(0), Fraction(1)]
    mu = {
        "a": [[Fraction(1), Fraction(1)], [Fraction(0), Fraction(1)]],
        "b": [[Fraction(1), Fraction(0)], [Fraction(0), Fraction(1)]],
    }
    count_a = linear_rep_series(lam, mu, gam)
    print("  f(w) = |w|_a (number of a's) has the 2-dimensional representation")
    print("     lambda = (1,0),  mu(a) = [[1,1],[0,1]],  mu(b) = I,  gamma = (0,1)")
    for word in [w(""), w("a"), w("ab"), w("aab"), w("baba")]:
        print(f"     f({show(word):>5}) = {count_a(word)}")
    print(f"  Hankel ranks at depths 1,2,3 : "
          f"{[hankel_rank(count_a, 'ab', d) for d in (1, 2, 3)]}   (stabilises at 2)")

    print("\n  Factorisation f(uv) = sum_i g_i(u) h_i(v) read off the representation:")
    ok = True
    for u in all_words("ab", 3):
        for v in all_words("ab", 3):
            g1, g2 = count_a(u), Fraction(1)
            h1, h2 = Fraction(1), count_a(v)
            ok &= (count_a(u + v) == g1 * h1 + g2 * h2)
    print(f"     |uv|_a = |u|_a·1 + 1·|v|_a for all |u|,|v| <= 3 : {ok}")

    print("\n  Rationality is preserved by the shuffle product of series:")
    two_pow = linear_rep_series([Fraction(1)], {"a": [[Fraction(2)]], "b": [[Fraction(2)]]},
                                [Fraction(1)])
    prod = shuffle_series(count_a, two_pow)
    print(f"     f = |w|_a  (rank 2),  g = 2^|w|  (rank 1)")
    for word in [w(""), w("a"), w("ab"), w("aba")]:
        print(f"     (f shuffle g)({show(word):>4}) = {prod(word)}")
    print(f"     Hankel ranks of f shuffle g at depths 1,2,3 : "
          f"{[hankel_rank(prod, 'ab', d) for d in (1, 2, 3)]}   (bounded: still rational)")

    print("\n  The shuffle of series extends the shuffle of words:")
    u, v = w("ab"), w("a")

    def dirac(x: Word) -> Series:
        return lambda z: Fraction(1) if z == x else Fraction(0)

    dprod = shuffle_series(dirac(u), dirac(v))
    sh = shuffle(u, v)
    ok = all(dprod(z) == sh[z] for z in all_words("ab", 3))
    print(f"     (delta_{show(u)} shuffle delta_{show(v)})(z) = multiplicity of z "
          f"in {show(u)} shuffle {show(v)} : {ok}")

    print("\n  The counit is the unit, and the shuffle of series is associative:")
    words = all_words("ab", 3)
    unit_ok = all(shuffle_series(counit, count_a)(z) == count_a(z) for z in words)
    left = shuffle_series(shuffle_series(count_a, two_pow), counit)
    right = shuffle_series(count_a, shuffle_series(two_pow, counit))
    assoc_ok = all(left(z) == right(z) for z in words)
    print(f"     eps shuffle f = f : {unit_ok}     associativity : {assoc_ok}")


def demo_separation() -> None:
    print()
    print("=" * 76)
    print("5. The separation theorem: group-like series are never rational")
    print("=" * 76)
    print("  The Hankel matrix of exp(a) restricted to the powers of a is [1/(i+j)!].")
    print("  Its leading minors are nonzero, so its rank is infinite:")
    for n in range(1, 8):
        m = [[Fraction(1, factorial(i + j)) for j in range(n)] for i in range(n)]
        d = determinant(m)
        print(f"    n = {n}: det [1/(i+j)!]_{{0<=i,j<{n}}} = {d}  (nonzero: {d != 0})")

    c = {"a": Fraction(1)}
    ep = exp_plane(c)
    print("\n  Hankel ranks of exp(a) at growing depths (over the one-letter alphabet):")
    print(f"    {[hankel_rank(ep, 'a', d) for d in (1, 2, 3, 4, 5)]}   -> unbounded")
    print("  Hence exp(l) is a shuffle character which is NOT representative,")
    print("  while the Kleene star l* is representative of rank one but is a shuffle")
    print("  character only in the degenerate case l = 0: the two character groups of")
    print("  the two bialgebras meet exactly in the counit.")


def main() -> None:
    demo_shuffle_basics()
    demo_duality()
    demo_characters()
    demo_representative()
    demo_separation()
    print()
    print("All demonstrations completed.")


if __name__ == "__main__":
    main()
