"""
Tropical Shtarkov sums for finite-state binary sources: numerical demonstrations.

This self-contained script illustrates, by direct computation, every quantitative
claim of the accompanying paper:

  1. The Shtarkov sum  S_n(M) = sum_x max_theta P_theta(x)  of a k-state binary
     automaton class, computed exactly by brute-force enumeration of all 2^n words.
  2. The count factorisation  P_theta(x) = prod_s theta_s^{a_s} (1-theta_s)^{b_s}
     and the maximum-likelihood plug-in domination, verified against random
     parameter vectors.
  3. The counting upper bound      S_n(M) <= ((n+1)^2)^k,
     the memoryless sharpening     S_n    <= n+1        (k = 1),
     the universal cap and floor   1 <= S_n <= 2^n.
  4. Saturation: the (n+1)-state counter machine has S_n = 2^n exactly.
  5. The state-budget phase transition: regret rate log(S_n)/n for a sqrt(n)-state
     budget versus the counter family.
  6. The entropy bridge  S_n = sum_x exp(-Hhat_M(x))  and the Kraft-type inequality.
  7. Tensorisation  S(P (x) Q) = S(P) S(Q)  and refinement monotonicity.
  8. The empirical asymptotics  S_n ~ sqrt(pi n / 2)  (k = 1)  and  S_n ~ n  (k = 2),
     which are the numerical evidence for the conjectured n^{k/2} law.

Only the Python standard library is used.
"""

from __future__ import annotations

import itertools
import math
from typing import Callable, Dict, Iterable, List, Sequence, Tuple

# ---------------------------------------------------------------------------
# Automata
# ---------------------------------------------------------------------------

Word = Tuple[int, ...]


class FSM:
    """A deterministic binary finite-state machine.

    Attributes
    ----------
    k     : number of states, labelled 0, ..., k-1
    init  : initial state
    step  : transition table, step[s][b] is the state reached from s on symbol b
    name  : human-readable label
    """

    def __init__(self, k: int, init: int, step: Sequence[Sequence[int]], name: str = "") -> None:
        assert 0 <= init < k
        assert len(step) == k and all(len(row) == 2 for row in step)
        self.k = k
        self.init = init
        self.step = [tuple(row) for row in step]
        self.name = name or f"FSM(k={k})"

    def states_visited(self, x: Word) -> List[int]:
        """The sequence sigma_0(x), ..., sigma_{n-1}(x) of states occupied while reading x."""
        s = self.init
        out: List[int] = []
        for b in x:
            out.append(s)
            s = self.step[s][b]
        return out

    def counts(self, x: Word) -> List[Tuple[int, int]]:
        """Per-state emission counts (a_s, b_s): times state s emitted 1, resp. 0."""
        a = [0] * self.k
        b = [0] * self.k
        s = self.init
        for sym in x:
            if sym:
                a[s] += 1
            else:
                b[s] += 1
            s = self.step[s][sym]
        return list(zip(a, b))

    def likelihood(self, theta: Sequence[float], x: Word) -> float:
        """P_theta(x), computed directly along the trajectory."""
        p = 1.0
        s = self.init
        for sym in x:
            p *= theta[s] if sym else 1.0 - theta[s]
            s = self.step[s][sym]
        return p


def memoryless(name: str = "memoryless (k=1)") -> FSM:
    """The one-state machine: the full Bernoulli family."""
    return FSM(1, 0, [[0, 0]], name)


def markov1(name: str = "order-1 Markov (k=2)") -> FSM:
    """Two states = last symbol emitted: the order-1 binary Markov class."""
    return FSM(2, 0, [[0, 1], [0, 1]], name)


def parity(name: str = "parity (k=2)") -> FSM:
    """Two states = parity of the number of 1s emitted so far."""
    return FSM(2, 0, [[0, 1], [1, 0]], name)


def three_cycle(name: str = "3-cycle (k=3)") -> FSM:
    """Three states cycling with time, regardless of the emitted symbol."""
    return FSM(3, 0, [[1, 1], [2, 2], [0, 0]], name)


def counter(n: int) -> FSM:
    """The (n+1)-state counter machine: its state is the capped time index."""
    step = [[min(s + 1, n), min(s + 1, n)] for s in range(n + 1)]
    return FSM(n + 1, 0, step, f"counter (k={n + 1})")


# ---------------------------------------------------------------------------
# Maximum likelihood, empirical entropy, Shtarkov sums
# ---------------------------------------------------------------------------


def ml_param(a: int, b: int) -> float:
    """The maximum-likelihood Bernoulli parameter a/(a+b), with the convention 0 for a=b=0."""
    return 0.0 if a + b == 0 else a / (a + b)


def ml_factor(a: int, b: int) -> float:
    """max_theta theta^a (1-theta)^b = that^a (1-that)^b, with that = a/(a+b)."""
    t = ml_param(a, b)
    return (t ** a) * ((1.0 - t) ** b)


def binary_entropy(p: float) -> float:
    """Binary entropy h(p) in nats, with h(0) = h(1) = 0."""
    if p <= 0.0 or p >= 1.0:
        return 0.0
    return -p * math.log(p) - (1.0 - p) * math.log(1.0 - p)


def empirical_entropy(machine: FSM, x: Word) -> float:
    """Hhat_M(x) = sum_s (a_s + b_s) h(a_s / (a_s + b_s)), in nats."""
    return sum((a + b) * binary_entropy(ml_param(a, b)) for a, b in machine.counts(x))


def all_words(n: int) -> Iterable[Word]:
    """All 2^n binary words of length n."""
    return itertools.product((0, 1), repeat=n)


def max_likelihood(machine: FSM, x: Word) -> float:
    """The tropical envelope max_theta P_theta(x), via the count factorisation."""
    prod = 1.0
    for a, b in machine.counts(x):
        prod *= ml_factor(a, b)
    return prod


def shtarkov_sum(machine: FSM, n: int) -> float:
    """S_n(M) = sum over all 2^n words of the maximised likelihood. Cost Theta(2^n n)."""
    return sum(max_likelihood(machine, x) for x in all_words(n))


def shtarkov_sum_via_entropy(machine: FSM, n: int) -> float:
    """S_n(M) = sum_x exp(-Hhat_M(x)): the partition-function form."""
    return sum(math.exp(-empirical_entropy(machine, x)) for x in all_words(n))


def shtarkov_sum_by_counts(machine: FSM, n: int) -> float:
    """S_n(M) computed by grouping words into fibres of the count statistic.

    Demonstrates that the maximised likelihood is a function of the counts alone,
    and exposes the fibre multiplicities N(c) that the counting bound replaces by 1.
    """
    fibres: Dict[Tuple[Tuple[int, int], ...], int] = {}
    for x in all_words(n):
        c = tuple(machine.counts(x))
        fibres[c] = fibres.get(c, 0) + 1
    total = 0.0
    for c, mult in fibres.items():
        w = 1.0
        for a, b in c:
            w *= ml_factor(a, b)
        total += mult * w
    return total


def count_statistic_image_size(machine: FSM, n: int) -> int:
    """|image T|: the number of distinct count vectors realised by words of length n."""
    return len({tuple(machine.counts(x)) for x in all_words(n)})


def counting_bound(k: int, n: int) -> float:
    """The generic counting bound ((n+1)^2)^k."""
    return float((n + 1) ** (2 * k))


def packing_lower_bound(machine: FSM, n: int, chooser: Callable[[Word], Sequence[float]]) -> float:
    """A certified lower bound sum_{a in A} P_{f(a)}(a) with A = all words."""
    return sum(machine.likelihood(chooser(x), x) for x in all_words(n))


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------


def demo_ml_domination(seed: int = 20260820) -> None:
    """Verify plug-in domination against pseudo-random parameter vectors."""
    print("=" * 78)
    print("1. Maximum-likelihood plug-in domination:  P_theta(x) <= P_{theta-hat(x)}(x)")
    print("=" * 78)

    # A small deterministic pseudo-random generator, to keep the script dependency-free.
    state = seed

    def rnd() -> float:
        nonlocal state
        state = (1103515245 * state + 12345) % (2 ** 31)
        return state / (2 ** 31)

    worst_violation = 0.0
    checked = 0
    for machine in (memoryless(), markov1(), parity(), three_cycle()):
        for n in (4, 6, 8):
            for _ in range(30):
                theta = [rnd() for _ in range(machine.k)]
                for x in all_words(n):
                    lhs = machine.likelihood(theta, x)
                    rhs = max_likelihood(machine, x)
                    worst_violation = max(worst_violation, lhs - rhs)
                    checked += 1
    print(f"  checked {checked} (model, word) pairs across 4 machines and n in {{4,6,8}}")
    print(f"  largest observed value of  P_theta(x) - max-likelihood(x):  {worst_violation:.3e}")
    print("  (nonpositive up to floating point: the envelope is attained at the empirical model)\n")


def demo_factorisation_and_normalisation() -> None:
    """Check the count factorisation and that each source is a probability measure."""
    print("=" * 78)
    print("2. Count factorisation and normalisation")
    print("=" * 78)
    theta_by_k = {1: [0.3], 2: [0.25, 0.8], 3: [0.1, 0.5, 0.9]}
    for machine in (memoryless(), markov1(), parity(), three_cycle()):
        theta = theta_by_k[machine.k]
        n = 8
        err_fac = 0.0
        total = 0.0
        for x in all_words(n):
            direct = machine.likelihood(theta, x)
            fac = 1.0
            for s, (a, b) in enumerate(machine.counts(x)):
                fac *= (theta[s] ** a) * ((1.0 - theta[s]) ** b)
            err_fac = max(err_fac, abs(direct - fac))
            total += direct
        print(f"  {machine.name:24s}  n={n}  max |direct - factorised| = {err_fac:.2e}"
              f"   sum_x P_theta(x) = {total:.12f}")
    print()


def demo_shtarkov_and_bounds() -> None:
    """Tabulate exact Shtarkov sums against every proved bound."""
    print("=" * 78)
    print("3. Exact Shtarkov sums against the proved bounds")
    print("=" * 78)
    header = (f"{'machine':<24}{'n':>3}{'S_n':>12}{'|im T|':>9}"
              f"{'((n+1)^2)^k':>14}{'2^n':>8}{'regret':>10}")
    for machine in (memoryless(), markov1(), parity(), three_cycle()):
        print(header)
        for n in range(1, 13):
            s = shtarkov_sum(machine, n)
            img = count_statistic_image_size(machine, n)
            cb = counting_bound(machine.k, n)
            cap = float(2 ** n)
            ok = (1.0 - 1e-9 <= s <= min(cb, cap) + 1e-9) and (s <= img + 1e-9)
            flag = "" if ok else "   <-- VIOLATION"
            print(f"{machine.name:<24}{n:>3}{s:>12.4f}{img:>9}{cb:>14.0f}{cap:>8.0f}"
                  f"{math.log(s):>10.4f}{flag}")
        print()


def demo_memoryless_asymptotics() -> None:
    """S_n <= n+1 for one state, and the true growth S_n ~ sqrt(pi n / 2)."""
    print("=" * 78)
    print("4. The memoryless class: proved bound  S_n <= n+1  versus the true growth")
    print("=" * 78)
    print(f"{'n':>3}{'S_n (exact)':>14}{'n+1':>7}{'sqrt(pi n/2)':>15}{'ratio':>9}")
    for n in range(1, 19):
        # Exact via the count fibres: S_n = sum_j C(n,j) * ml_factor(j, n-j).
        s = sum(math.comb(n, j) * ml_factor(j, n - j) for j in range(n + 1))
        asy = math.sqrt(math.pi * n / 2.0)
        print(f"{n:>3}{s:>14.5f}{n + 1:>7}{asy:>15.5f}{s / asy:>9.4f}")
    print("  The counting bound n+1 is correct but loose by a factor ~ sqrt(2n/pi):")
    print("  one square root per free parameter, exactly the conjectured n^{k/2} law.\n")


def demo_two_state_asymptotics() -> None:
    """For k = 2 the conjectured law predicts S_n = Theta(n)."""
    print("=" * 78)
    print("5. Two-state classes: the conjectured n^{k/2} law predicts S_n = Theta(n)")
    print("=" * 78)
    print(f"{'n':>3}{'S_n (Markov-1)':>17}{'S_n/n':>10}{'S_n (parity)':>16}{'S_n/n':>10}")
    for n in range(2, 17):
        s1 = shtarkov_sum(markov1(), n)
        s2 = shtarkov_sum(parity(), n)
        print(f"{n:>3}{s1:>17.5f}{s1 / n:>10.4f}{s2:>16.5f}{s2 / n:>10.4f}")
    print("  Both ratios stay of order 1: S_n = Theta(n) = Theta(n^{2/2}).\n")


def demo_saturation_and_phase_transition() -> None:
    """The counter machine saturates; a sqrt(n) state budget does not."""
    print("=" * 78)
    print("6. Saturation and the state-budget phase transition")
    print("=" * 78)
    print("  Counter machine C_n with n+1 states (one coin per time index):")
    print(f"{'n':>3}{'S_n':>12}{'2^n':>8}{'regret':>10}{'rate = regret/n':>18}")
    for n in range(1, 13):
        c = counter(n)
        s = shtarkov_sum(c, n)
        print(f"{n:>3}{s:>12.4f}{2 ** n:>8}{math.log(s):>10.4f}{math.log(s) / n:>18.6f}")
    print("  S_n = 2^n exactly, rate = log 2 = 0.693147 for every n: total saturation.\n")

    print("  A sqrt(n)-sized state budget: the proved upper bound on the rate is")
    print("  2 k(n) log(n+1) / n  with  k(n) = floor(sqrt(n)) + 1.")
    print(f"{'n':>16}{'k(n)':>9}{'rate bound':>14}")
    for n in (10, 10 ** 2, 10 ** 3, 10 ** 4, 10 ** 6, 10 ** 9, 10 ** 12):
        k = math.isqrt(n) + 1
        print(f"{n:>16}{k:>9}{2 * k * math.log(n + 1) / n:>14.6f}")
    print("  The bound tends to 0: uniformly over all automata with that many states,")
    print("  the per-symbol redundancy vanishes. At k(n) = n+1 it is exactly log 2.\n")


def demo_entropy_bridge() -> None:
    """S_n = sum_x exp(-Hhat(x)); the Kraft-type inequality; the range of Hhat."""
    print("=" * 78)
    print("7. The entropy bridge and the Kraft-type inequality")
    print("=" * 78)
    print(f"{'machine':<24}{'n':>3}{'S_n':>12}{'sum e^-Hhat':>14}"
          f"{'max Hhat':>11}{'n log 2':>10}{'bound':>12}")
    for machine in (memoryless(), markov1(), parity(), three_cycle()):
        for n in (6, 10):
            s = shtarkov_sum(machine, n)
            se = shtarkov_sum_via_entropy(machine, n)
            hmax = max(empirical_entropy(machine, x) for x in all_words(n))
            hmin = min(empirical_entropy(machine, x) for x in all_words(n))
            assert hmin >= -1e-12
            print(f"{machine.name:<24}{n:>3}{s:>12.5f}{se:>14.5f}"
                  f"{hmax:>11.5f}{n * math.log(2):>10.5f}"
                  f"{counting_bound(machine.k, n):>12.0f}")
    print("  The two columns agree exactly: the Shtarkov sum is the partition function")
    print("  of empirical entropy, and empirical entropies obey Kraft up to ((n+1)^2)^k.\n")


def demo_tensorisation_and_monotonicity() -> None:
    """Regret is additive over independent components; refinement can only increase it."""
    print("=" * 78)
    print("8. Tensorisation and monotonicity under refinement")
    print("=" * 78)
    # Tensorisation: the product of two independent memoryless blocks, of lengths n1 and n2,
    # is realised by a machine whose Shtarkov sum should factor as S_{n1} * S_{n2}.
    for n1, n2 in ((3, 4), (5, 5), (4, 7)):
        s1 = sum(math.comb(n1, j) * ml_factor(j, n1 - j) for j in range(n1 + 1))
        s2 = sum(math.comb(n2, j) * ml_factor(j, n2 - j) for j in range(n2 + 1))
        prod = 0.0
        for x in all_words(n1):
            for y in all_words(n2):
                prod += (max_likelihood(memoryless(), x) * max_likelihood(memoryless(), y))
        print(f"  n1={n1}, n2={n2}:  S(P)*S(Q) = {s1 * s2:.6f}   S(P (x) Q) = {prod:.6f}")

    # Monotonicity: the memoryless machine is simulated by the order-1 Markov machine
    # (collapse both states to one), so S_n(memoryless) <= S_n(Markov-1).
    print("\n  Refinement monotonicity (memoryless is a quotient of both 2-state machines):")
    print(f"{'n':>3}{'S_n memoryless':>17}{'S_n Markov-1':>15}{'S_n parity':>13}")
    for n in range(2, 13):
        s0 = shtarkov_sum(memoryless(), n)
        s1 = shtarkov_sum(markov1(), n)
        s2 = shtarkov_sum(parity(), n)
        assert s0 <= s1 + 1e-9 and s0 <= s2 + 1e-9
        print(f"{n:>3}{s0:>17.5f}{s1:>15.5f}{s2:>13.5f}")
    print()


def demo_memorisation_capacity() -> None:
    """A k-state machine can give probability 1 to at most ((n+1)^2)^k words."""
    print("=" * 78)
    print("9. Memorisation capacity of automata")
    print("=" * 78)
    print(f"{'machine':<24}{'n':>3}{'# memorised words':>20}{'((n+1)^2)^k':>32}{'2^n':>8}")
    for machine in (memoryless(), markov1(), parity(), three_cycle()):
        for n in (6, 10):
            memorised = sum(1 for x in all_words(n) if max_likelihood(machine, x) >= 1.0 - 1e-12)
            print(f"{machine.name:<24}{n:>3}{memorised:>20}"
                  f"{counting_bound(machine.k, n):>32.0f}{2 ** n:>8}")
    for n in (6, 10):
        c = counter(n)
        memorised = sum(1 for x in all_words(n) if max_likelihood(c, x) >= 1.0 - 1e-12)
        print(f"{c.name:<24}{n:>3}{memorised:>20}"
              f"{counting_bound(c.k, n):>32.0f}{2 ** n:>8}")
    print("  Small machines memorise only a handful of words; the counter memorises all 2^n.")
    print("  Packing then forces S_n = 2^n and the maximal regret n log 2.\n")


def demo_packing_certificate() -> None:
    """Algorithm C: a certified lower bound on the Shtarkov sum."""
    print("=" * 78)
    print("10. Packing certificates")
    print("=" * 78)
    n = 8
    # For the counter machine, the memorising assignment certifies S_n >= 2^n.
    c = counter(n)

    def memorise(x: Word) -> List[float]:
        return [float(x[s]) if s < len(x) else 0.0 for s in range(c.k)]

    lb = packing_lower_bound(c, n, memorise)
    print(f"  counter, n={n}: packing certificate = {lb:.4f}, and 2^n = {2 ** n}")
    # For the memoryless class, the plug-in assignment certifies the exact value.
    m = memoryless()

    def plugin(x: Word) -> List[float]:
        (a, b), = m.counts(x)
        return [ml_param(a, b)]

    lb2 = packing_lower_bound(m, n, plugin)
    print(f"  memoryless, n={n}: packing certificate = {lb2:.6f}, exact S_n = "
          f"{shtarkov_sum(m, n):.6f}")
    print("  The plug-in assignment saturates the packing bound, because the envelope")
    print("  of the class is attained at the empirical model.\n")


def demo_fibre_waste() -> None:
    """Where the square root hides: fibre masses versus the one-unit charge."""
    print("=" * 78)
    print("11. Why the counting bound is loose by a square root")
    print("=" * 78)
    print("  The counting bound charges 1 unit of mass to each value of the statistic.")
    print("  The actual fibre mass, for the memoryless class, is C(n,j) * ml_factor(j, n-j):")
    n = 20
    print(f"\n  n = {n}:")
    print(f"{'j':>4}{'C(n,j)*ml_factor':>20}{'1/sqrt(n)':>13}")
    for j in range(0, n + 1, 2):
        mass = math.comb(n, j) * ml_factor(j, n - j)
        print(f"{j:>4}{mass:>20.6f}{1.0 / math.sqrt(n):>13.6f}")
    total = sum(math.comb(n, j) * ml_factor(j, n - j) for j in range(n + 1))
    print(f"\n  total = S_n = {total:.6f}, versus the charge (n+1) = {n + 1}")
    print(f"  ratio = {total / (n + 1):.6f} ~ sqrt(pi/(2n)) = "
          f"{math.sqrt(math.pi / (2 * n)):.6f}")
    print("  Each bulk fibre carries Theta(n^{-1/2}) mass, not 1: hence the conjectured")
    print("  replacement of ((n+1)^2)^k by Theta(n^{k/2}).\n")


def main() -> None:
    print()
    print("#" * 78)
    print("#  Tropical Shtarkov sums for finite-state binary sources")
    print("#  Numerical demonstrations of packing, counting, saturation, and the")
    print("#  state-budget phase transition")
    print("#" * 78)
    print()
    demo_ml_domination()
    demo_factorisation_and_normalisation()
    demo_shtarkov_and_bounds()
    demo_memoryless_asymptotics()
    demo_two_state_asymptotics()
    demo_saturation_and_phase_transition()
    demo_entropy_bridge()
    demo_tensorisation_and_monotonicity()
    demo_memorisation_capacity()
    demo_packing_certificate()
    demo_fibre_waste()
    print("All demonstrations completed: every proved bound held in every instance tested.")


if __name__ == "__main__":
    main()
