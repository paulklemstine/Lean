"""
The Price of Universality: numerical demonstrations
===================================================

Self-contained numerical companion to the theory of minimax redundancy of
universal decompressors.

Central object.  For a class of sources S = {p_theta} on a finite message set X,
the *Shtarkov sum* is

    C_S = sum_{x in X} sup_theta p_theta(x),

and the minimax pointwise redundancy -- the *price of universality*, i.e. the
worst-case number of extra bits a single shared code must spend relative to the
code tailored to the true source -- equals exactly log2(C_S), attained by the
normalized maximum likelihood (NML) code q*(x) = sup_theta p_theta(x) / C_S.

What this script demonstrates:

 1. Exact Shtarkov sums for the memoryless (i.i.d.) class over an m-letter
    alphabet, by the method of types, and the sandwich
        log2 m  <=  log2 C_S  <=  (m-1) log2(n+1).
 2. The Rissanen asymptotic  log2 C_S = ((m-1)/2) log2 n + O(1)  -- i.e. the
    proved type bound overshoots the leading coefficient by a factor of 2.
 3. Exact multiplicativity of the Shtarkov sum under independent composition,
    C_S(S x T) = C_S(S) * C_S(T), verified by brute force on small classes.
 4. The sharing dichotomy: k independently parameterised blocks cost a price
    LINEAR in k, while one shared parameter over the same total length costs
    only a LOGARITHMIC price.
 5. The model-selection overhead: a union of M classes costs at most
    log2 M + max price, with equality for mutually singular models.
 6. Finite-state sources: the per-symbol price |S||A| log2(n+1) / n -> 0.
 7. Exchangeability: an arbitrary, non-parametric permutation-invariant class
    obeys the same (n+1)^(m-1) bound as the memoryless family.

Only the Python standard library is used.
"""

from __future__ import annotations

import itertools
import math
import random
from typing import Callable, Dict, Iterable, List, Sequence, Tuple

# ----------------------------------------------------------------------------
# 1.  Exact Shtarkov sums for the memoryless class, by the method of types
# ----------------------------------------------------------------------------


def compositions(n: int, m: int) -> Iterable[Tuple[int, ...]]:
    """Enumerate all m-tuples of nonnegative integers summing to n."""
    if m == 1:
        yield (n,)
        return
    for first in range(n + 1):
        for rest in compositions(n - first, m - 1):
            yield (first,) + rest


def multinomial(counts: Sequence[int]) -> int:
    """Number of words of length sum(counts) with the given letter counts."""
    total = sum(counts)
    value = math.factorial(total)
    for c in counts:
        value //= math.factorial(c)
    return value


def type_max_likelihood(counts: Sequence[int]) -> float:
    """max_theta prod_a theta_a^{N_a} = prod_a (N_a/n)^{N_a}, with 0^0 = 1.

    The maximum-likelihood parameter of a word of type N is the empirical
    distribution theta_a = N_a / n.
    """
    n = sum(counts)
    if n == 0:
        return 1.0
    value = 1.0
    for c in counts:
        if c > 0:
            value *= (c / n) ** c
    return value


def shtarkov_iid(n: int, m: int) -> float:
    """Exact Shtarkov sum of the memoryless class on A^n with |A| = m.

    C_S = sum over types N of  multinomial(N) * prod_a (N_a/n)^{N_a}.
    Complexity: O(binom(n+m-1, m-1)) terms.
    """
    if n == 0:
        return 1.0
    return sum(
        multinomial(counts) * type_max_likelihood(counts)
        for counts in compositions(n, m)
    )


def shtarkov_iid_log2(n: int, m: int) -> float:
    """log2 of the exact Shtarkov sum, computed stably in log space."""
    if n == 0:
        return 0.0
    terms: List[float] = []
    for counts in compositions(n, m):
        log_term = math.lgamma(n + 1)
        for c in counts:
            log_term -= math.lgamma(c + 1)
            if c > 0:
                log_term += c * math.log(c / n)
        terms.append(log_term)
    peak = max(terms)
    total = sum(math.exp(t - peak) for t in terms)
    return (peak + math.log(total)) / math.log(2.0)


def rissanen_asymptotic_log2(n: int, m: int) -> float:
    """The Shtarkov--Rissanen asymptotic for log2 C_S of the i.i.d. class:

        log C_S = ((m-1)/2) log(n / (2 pi)) + log( pi^{m/2} / Gamma(m/2) ) + o(1).

    For m = 2 this is log2 sqrt(pi n / 2).
    """
    ln = (m - 1) / 2.0 * math.log(n / (2.0 * math.pi)) + (
        (m / 2.0) * math.log(math.pi) - math.lgamma(m / 2.0)
    )
    return ln / math.log(2.0)


def demo_iid_sandwich() -> None:
    print("=" * 78)
    print("1.  Memoryless class: exact price versus the proved sandwich")
    print("=" * 78)
    print("    log2 m  <=  log2 C_S  <=  (m-1) log2(n+1)")
    print()
    for m in (2, 3, 4):
        print(f"  alphabet size m = {m}")
        header = f"    {'n':>6} {'C_S':>14} {'log2 C_S':>10} {'lower':>8} {'upper':>8} {'asympt':>9}"
        print(header)
        for n in (4, 8, 16, 32, 64, 128):
            c = shtarkov_iid(n, m)
            price = math.log2(c)
            lower = math.log2(m)
            upper = (m - 1) * math.log2(n + 1)
            asym = rissanen_asymptotic_log2(n, m)
            assert lower <= price + 1e-9, "packing lower bound violated"
            assert price <= upper + 1e-9, "type upper bound violated"
            print(f"    {n:>6} {c:>14.4f} {price:>10.4f} {lower:>8.4f} {upper:>8.4f} {asym:>9.4f}")
        print()


def demo_binary_leading_coefficient() -> None:
    print("=" * 78)
    print("2.  Binary class: the true leading coefficient is 1/2, not 1")
    print("=" * 78)
    print("    proved:   (1/2) log2 n - 2  <=  log2 C_S  <=  log2 (n+1)")
    print("    truth:    log2 C_S = (1/2) log2 n + (1/2) log2(pi/2) + o(1)")
    print()
    print(f"    {'n':>8} {'log2 C_S':>10} {'(1/2)log2 n':>12} {'difference':>11} {'sqrt(pi n/2)':>13}")
    for n in (32, 128, 512, 2048, 8192, 32768):
        price = shtarkov_iid_log2(n, 2)
        half = 0.5 * math.log2(n)
        print(
            f"    {n:>8} {price:>10.4f} {half:>12.4f} {price - half:>11.4f}"
            f" {math.sqrt(math.pi * n / 2):>13.4f}"
        )
    print()
    print(f"    (1/2) log2(pi/2) = {0.5 * math.log2(math.pi / 2):.4f}  <- the limit of the difference")
    print()


# ----------------------------------------------------------------------------
# 3.  Multiplicativity of the Shtarkov sum, verified by brute force
# ----------------------------------------------------------------------------


Distribution = Tuple[float, ...]


def shtarkov_of_finite_class(sources: Sequence[Distribution]) -> float:
    """C_S of a class given as an explicit finite list of distributions."""
    n_messages = len(sources[0])
    return sum(max(p[x] for p in sources) for x in range(n_messages))


def tensor_class(
    left: Sequence[Distribution], right: Sequence[Distribution]
) -> List[Distribution]:
    """All product sources p_theta (x) p_psi on the product message set."""
    out: List[Distribution] = []
    for p in left:
        for q in right:
            out.append(tuple(pi * qi for pi in p for qi in q))
    return out


def random_class(n_sources: int, n_messages: int, rng: random.Random) -> List[Distribution]:
    """A random source class: n_sources distributions on n_messages messages."""
    cls: List[Distribution] = []
    for _ in range(n_sources):
        weights = [rng.random() + 1e-3 for _ in range(n_messages)]
        total = sum(weights)
        cls.append(tuple(w / total for w in weights))
    return cls


def demo_multiplicativity() -> None:
    print("=" * 78)
    print("3.  Exact multiplicativity:  C_S(S (x) T) = C_S(S) * C_S(T)")
    print("=" * 78)
    rng = random.Random(20260818)
    print(f"    {'trial':>6} {'C_S(S)':>10} {'C_S(T)':>10} {'product':>12} {'C_S(S(x)T)':>12} {'error':>10}")
    for trial in range(1, 6):
        s = random_class(rng.randint(2, 5), rng.randint(2, 5), rng)
        t = random_class(rng.randint(2, 5), rng.randint(2, 5), rng)
        cs, ct = shtarkov_of_finite_class(s), shtarkov_of_finite_class(t)
        cst = shtarkov_of_finite_class(tensor_class(s, t))
        err = abs(cst - cs * ct)
        assert err < 1e-12, "multiplicativity failed"
        print(f"    {trial:>6} {cs:>10.6f} {ct:>10.6f} {cs * ct:>12.6f} {cst:>12.6f} {err:>10.2e}")
    print()
    print("    Consequence: the price of universality is ADDITIVE over")
    print("    independently parameterised blocks:  R(S^k) = k * R(S).")
    print()


# ----------------------------------------------------------------------------
# 4.  The sharing dichotomy
# ----------------------------------------------------------------------------


def demo_sharing_dichotomy(block_length: int = 32) -> None:
    print("=" * 78)
    print(f"4.  Sharing dichotomy at block length n = {block_length}")
    print("=" * 78)
    print("    k independent Bernoulli blocks of length n  vs.  one shared bias")
    print("    over the same total length k*n.")
    print()
    per_block = shtarkov_iid_log2(block_length, 2)
    print(f"    price of one block  = {per_block:.4f} bits")
    print()
    print(f"    {'k':>7} {'total len':>10} {'independent':>13} {'shared':>9} {'gap':>12} {'k/4':>10}")
    for k in (1, 10, 100, 1000, 5000, 20000):
        independent = k * per_block
        shared = shtarkov_iid_log2(k * block_length, 2)
        gap = independent - shared
        flag = "  <= gap" if k >= 5000 and gap >= k / 4 else ""
        print(
            f"    {k:>7} {k * block_length:>10} {independent:>13.2f} {shared:>9.3f}"
            f" {gap:>12.2f} {k / 4:>10.2f}{flag}"
        )
    print()
    print("    The proved theorem: for k >= 5000 and n = 32 the gap is at least k/4 bits.")
    print("    Those are exactly the bits a specialised decompressor absorbs for free.")
    print()


# ----------------------------------------------------------------------------
# 5.  Model selection: unions of classes
# ----------------------------------------------------------------------------


def union_class(classes: Sequence[Sequence[Distribution]]) -> List[Distribution]:
    """The union of several classes on a common message set."""
    return [p for cls in classes for p in cls]


def demo_model_selection() -> None:
    print("=" * 78)
    print("5.  Model selection: log2 M bits to name the model, and no more")
    print("=" * 78)
    rng = random.Random(11235)

    # (a) generic overlapping models: strict subadditivity.
    n_messages = 8
    models = [random_class(3, n_messages, rng) for _ in range(4)]
    prices = [math.log2(shtarkov_of_finite_class(c)) for c in models]
    union_price = math.log2(shtarkov_of_finite_class(union_class(models)))
    bound = math.log2(len(models)) + max(prices)
    print("    (a) four generic overlapping models on 8 messages")
    print(f"        individual prices : {[f'{p:.4f}' for p in prices]}")
    print(f"        union price       : {union_price:.4f} bits")
    print(f"        bound log2 M + max: {bound:.4f} bits")
    print(f"        every member <= union: {all(p <= union_price + 1e-12 for p in prices)}")
    assert union_price <= bound + 1e-12

    # (b) mutually singular models: the log2 M overhead is exactly attained.
    print()
    print("    (b) four MUTUALLY SINGULAR models (disjoint supports)")
    block = 4
    singular: List[List[Distribution]] = []
    for i in range(4):
        cls: List[Distribution] = []
        for p in random_class(3, block, rng):
            full = [0.0] * (4 * block)
            full[i * block : (i + 1) * block] = list(p)
            cls.append(tuple(full))
        singular.append(cls)
    sing_prices = [math.log2(shtarkov_of_finite_class(c)) for c in singular]
    sing_union = math.log2(shtarkov_of_finite_class(union_class(singular)))
    exact = math.log2(sum(shtarkov_of_finite_class(c) for c in singular))
    print(f"        individual prices : {[f'{p:.4f}' for p in sing_prices]}")
    print(f"        union price       : {sing_union:.4f} bits")
    print(f"        sum of Shtarkov sums (exact identity): {exact:.4f} bits")
    print(f"        overhead over the max member: {sing_union - max(sing_prices):.4f} bits"
          f"   (log2 4 = {math.log2(4):.4f} when the members are equal)")
    assert abs(sing_union - exact) < 1e-12
    print()


# ----------------------------------------------------------------------------
# 6.  Finite-state sources: the per-symbol price vanishes
# ----------------------------------------------------------------------------


def fsm_price_bound_bits(n_states: int, alphabet_size: int, n: int) -> float:
    """The proved bound |S| * |A| * log2(n+1) on the price of a finite-state class."""
    return n_states * alphabet_size * math.log2(n + 1)


def fsm_likelihood(
    transition: Callable[[int, int], int],
    emission: Sequence[Sequence[float]],
    initial_state: int,
    word: Sequence[int],
) -> float:
    """Likelihood of a word under a finite-state source: the product of the
    emission probabilities along the deterministic state trajectory."""
    state = initial_state
    value = 1.0
    for letter in word:
        value *= emission[state][letter]
        state = transition(state, letter)
    return value


def demo_finite_state() -> None:
    print("=" * 78)
    print("6.  Finite-state sources: per-symbol price -> 0")
    print("=" * 78)

    # A concrete two-state automaton over a binary alphabet: state = last letter.
    transition = lambda _state, letter: letter
    emission = [[0.9, 0.1], [0.3, 0.7]]
    word = [0, 0, 1, 1, 0, 1, 1, 1]
    lik = fsm_likelihood(transition, emission, 0, word)
    print(f"    two-state automaton (state = previous letter), emission {emission}")
    print(f"    likelihood of {word} = {lik:.8f}")
    total = sum(
        fsm_likelihood(transition, emission, 0, w)
        for w in itertools.product((0, 1), repeat=len(word))
    )
    print(f"    total mass over all {2 ** len(word)} words of that length = {total:.12f}")
    assert abs(total - 1.0) < 1e-12
    print()
    print("    proved bound   price <= |S| * |A| * log2(n+1)   and price/n -> 0:")
    print(f"    {'n':>9} {'|S|=2,|A|=2':>13} {'per symbol':>12} {'|S|=64,|A|=256':>16} {'per symbol':>12}")
    for n in (10, 100, 10 ** 3, 10 ** 5, 10 ** 7, 10 ** 9):
        small = fsm_price_bound_bits(2, 2, n)
        big = fsm_price_bound_bits(64, 256, n)
        print(f"    {n:>9} {small:>13.2f} {small / n:>12.3e} {big:>16.2f} {big / n:>12.3e}")
    print()
    print("    A large automaton only changes the constant, never the rate.")
    print()


# ----------------------------------------------------------------------------
# 7.  Exchangeability: symmetry, not parametricity, is what makes coding cheap
# ----------------------------------------------------------------------------


def word_type(word: Sequence[int], alphabet_size: int) -> Tuple[int, ...]:
    counts = [0] * alphabet_size
    for letter in word:
        counts[letter] += 1
    return tuple(counts)


def random_exchangeable_source(
    n: int, alphabet_size: int, rng: random.Random
) -> Dict[Tuple[int, ...], float]:
    """A random exchangeable law on A^n: an arbitrary probability vector over
    TYPES, spread uniformly inside each type class.  No i.i.d. structure, no
    parameters -- just permutation invariance."""
    types = list(compositions(n, alphabet_size))
    weights = [rng.random() for _ in types]
    total = sum(weights)
    return {t: w / total / multinomial(t) for t, w in zip(types, weights)}


def demo_exchangeable() -> None:
    print("=" * 78)
    print("7.  Exchangeable classes: cheap however wild")
    print("=" * 78)
    print("    Theorem:  ANY permutation-invariant class on A^n has")
    print("              C_S <= (n+1)^(|A|-1),  price <= (|A|-1) log2(n+1).")
    print()
    rng = random.Random(31415)
    for n, m, n_sources in ((6, 2, 40), (8, 2, 60), (5, 3, 40)):
        sources = [random_exchangeable_source(n, m, rng) for _ in range(n_sources)]
        words = list(itertools.product(range(m), repeat=n))
        # sanity: each source is a probability distribution and is exchangeable
        for src in sources[:3]:
            mass = sum(src[word_type(w, m)] for w in words)
            assert abs(mass - 1.0) < 1e-9
        c_s = sum(max(src[word_type(w, m)] for src in sources) for w in words)
        price = math.log2(c_s)
        bound = (m - 1) * math.log2(n + 1)
        assert price <= bound + 1e-9
        print(
            f"    n={n:>2}, |A|={m}, {n_sources} random exchangeable sources:"
            f"  price = {price:.4f} bits  <=  bound {bound:.4f} bits"
        )
    print()
    print("    Even the class of ALL exchangeable laws is bounded the same way:")
    for n in (10, 100, 1000):
        print(f"        binary, n = {n:>4}:  price <= log2(n+1) = {math.log2(n + 1):.4f} bits")
    print()


# ----------------------------------------------------------------------------
# 8.  The NML code itself
# ----------------------------------------------------------------------------


def nml_code_lengths(n: int, m: int) -> Dict[Tuple[int, ...], float]:
    """Code length (in bits) that the optimal universal code assigns to each
    type class of A^n for the memoryless class:
        -log2 maxlik(N) + log2 C_S   for one representative word of type N.
    """
    c_s = shtarkov_iid(n, m)
    lengths: Dict[Tuple[int, ...], float] = {}
    for counts in compositions(n, m):
        lengths[counts] = -math.log2(type_max_likelihood(counts)) + math.log2(c_s)
    return lengths


def demo_nml_code() -> None:
    print("=" * 78)
    print("8.  The optimal universal code (normalized maximum likelihood)")
    print("=" * 78)
    n, m = 12, 2
    lengths = nml_code_lengths(n, m)
    print(f"    binary messages of length n = {n};  price = {math.log2(shtarkov_iid(n, m)):.4f} bits")
    print()
    print(f"    {'type (#0,#1)':>14} {'-log2 maxlik':>14} {'NML length':>12} {'redundancy':>12}")
    for counts in sorted(lengths, reverse=True):
        maxlik = type_max_likelihood(counts)
        print(
            f"    {str(counts):>14} {-math.log2(maxlik):>14.4f} {lengths[counts]:>12.4f}"
            f" {lengths[counts] + math.log2(maxlik):>12.4f}"
        )
    print()
    print("    The redundancy column is CONSTANT: the NML code is exactly minimax,")
    print("    paying the same log2 C_S bits on every message and every source.")
    print()


def main() -> None:
    print()
    print("#" * 78)
    print("#  THE PRICE OF UNIVERSALITY -- numerical demonstrations")
    print("#" * 78)
    print()
    demo_iid_sandwich()
    demo_binary_leading_coefficient()
    demo_multiplicativity()
    demo_sharing_dichotomy()
    demo_model_selection()
    demo_finite_state()
    demo_exchangeable()
    demo_nml_code()
    print("All assertions passed.")


if __name__ == "__main__":
    main()
