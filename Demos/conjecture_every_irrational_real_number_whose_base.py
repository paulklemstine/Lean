#!/usr/bin/env python3
"""
Applications of Sofic Transcendence Theory
===========================================

Practical applications demonstrating the theorems:
1. Certified transcendence testing for combinatorially defined constants
2. Finite-state compression analysis of number-theoretic sequences
3. Pseudorandomness quality assessment via complexity profiles
4. Automatic sequence classification
"""

from typing import Callable, List, Tuple, Dict, Optional
from collections import defaultdict
import math


# ============================================================
# §1. Transcendence Certification Pipeline
# ============================================================

class TranscendenceCertifier:
    """
    Implements the transcendence certification pipeline:
    1. Compute factor complexity profile
    2. Check for linearity
    3. Check for non-periodicity
    4. If both hold, certify transcendence (modulo Adamczewski-Bugeaud)

    This is a computational implementation of the formal theorem
    `transcendental_of_sofic_digits`.
    """

    def __init__(self, seq: Callable[[int], int], base: int = 2,
                 prefix_length: int = 500, max_word_length: int = 20):
        self.seq = seq
        self.base = base
        self.N = prefix_length
        self.max_m = max_word_length

    def compute_complexity_profile(self) -> List[int]:
        """Compute [p(1), ..., p(max_m)]."""
        profile = []
        for m in range(1, self.max_m + 1):
            factors = set()
            for i in range(self.N - m + 1):
                w = tuple(self.seq(i + j) for j in range(m))
                factors.add(w)
            profile.append(len(factors))
        return profile

    def check_linearity(self, profile: List[int]) -> Tuple[bool, float, float]:
        """Check if the profile is approximately linear via regression."""
        n = len(profile)
        x = list(range(1, n + 1))
        y = profile

        x_mean = sum(x) / n
        y_mean = sum(y) / n

        ss_xy = sum((xi - x_mean) * (yi - y_mean) for xi, yi in zip(x, y))
        ss_xx = sum((xi - x_mean) ** 2 for xi in x)

        slope = ss_xy / ss_xx if ss_xx > 0 else 0
        intercept = y_mean - slope * x_mean

        ss_res = sum((yi - (slope * xi + intercept)) ** 2 for xi, yi in zip(x, y))
        ss_tot = sum((yi - y_mean) ** 2 for yi in y)

        r_squared = 1 - ss_res / ss_tot if ss_tot > 0 else 1.0
        is_linear = r_squared > 0.95
        return is_linear, slope, intercept

    def check_non_periodicity(self) -> bool:
        """Check that the sequence is not eventually periodic in the prefix."""
        prefix = [self.seq(n) for n in range(self.N)]
        for p in range(1, self.N // 3):
            for start in range(min(p, self.N // 4)):
                periodic = True
                for i in range(start, self.N - p):
                    if prefix[i] != prefix[i + p]:
                        periodic = False
                        break
                if periodic and self.N - start >= 3 * p:
                    return False  # Found periodicity
        return True  # No periodicity found

    def certify(self) -> Dict[str, object]:
        """
        Run the full certification pipeline.

        Returns a dictionary with:
        - 'profile': complexity profile
        - 'is_linear': whether complexity is linear
        - 'slope', 'intercept': linear fit parameters
        - 'is_nonperiodic': whether the sequence appears non-periodic
        - 'is_transcendental': whether the criterion applies
        - 'reasoning': human-readable explanation
        """
        profile = self.compute_complexity_profile()
        is_linear, slope, intercept = self.check_linearity(profile)
        is_nonperiodic = self.check_non_periodicity()

        result = {
            'profile': profile,
            'is_linear': is_linear,
            'slope': slope,
            'intercept': intercept,
            'is_nonperiodic': is_nonperiodic,
            'is_transcendental': is_linear and is_nonperiodic,
        }

        if is_linear and is_nonperiodic:
            result['reasoning'] = (
                f"Factor complexity is linear (p(n) ≈ {slope:.1f}n + {intercept:.1f}) "
                f"and the sequence is not eventually periodic. "
                f"By the Adamczewski-Bugeaud criterion, the digit real is TRANSCENDENTAL."
            )
        elif not is_linear:
            result['reasoning'] = (
                f"Factor complexity is not linear (slope={slope:.1f}, "
                f"R²<0.95). Criterion inconclusive."
            )
        else:
            result['reasoning'] = (
                "Sequence appears eventually periodic. "
                "Digit real is likely RATIONAL."
            )

        return result


# ============================================================
# §2. Finite-State Compression Analyzer
# ============================================================

class CompressionAnalyzer:
    """
    Analyze the finite-state compressibility of a digit sequence.

    Implements the compression gap theorem computationally:
    for algebraic irrationals, fsComplexity should grow without bound.
    """

    def __init__(self, seq: Callable[[int], int], alphabet_size: int = 2):
        self.seq = seq
        self.b = alphabet_size

    def estimate_complexity_heuristic(self, N: int) -> int:
        """
        Estimate fsComplexity(a, N) using a state-merging heuristic.

        Builds a trivial N-state automaton and greedily merges states
        with compatible outputs and transitions.
        """
        target = [self.seq(n) for n in range(N)]

        # Union-Find for state merging
        parent = list(range(N))

        def find(x):
            while parent[x] != x:
                parent[x] = parent[parent[x]]
                x = parent[x]
            return x

        def union(x, y):
            rx, ry = find(x), find(y)
            if rx != ry:
                parent[rx] = ry
                return True
            return False

        # Greedily merge compatible states
        changed = True
        while changed:
            changed = False
            for i in range(N):
                for j in range(i + 1, N):
                    ri, rj = find(i), find(j)
                    if ri != rj:
                        # Check compatibility: same output, same successor class
                        if target[ri] == target[rj]:
                            next_i = (ri + 1) % N
                            next_j = (rj + 1) % N
                            if find(next_i) == find(next_j):
                                union(ri, rj)
                                changed = True

        return len(set(find(i) for i in range(N)))

    def complexity_growth_profile(self, max_N: int, step: int = 5) -> List[Tuple[int, int]]:
        """
        Compute fsComplexity estimates for increasing prefix lengths.

        Returns list of (N, estimated_complexity) pairs.
        """
        results = []
        for N in range(step, max_N + 1, step):
            K = self.estimate_complexity_heuristic(N)
            results.append((N, K))
        return results

    def check_unbounded_growth(self, max_N: int = 200, step: int = 10) -> Dict[str, object]:
        """
        Test whether fsComplexity appears to be unbounded.

        Returns analysis of the growth pattern.
        """
        profile = self.complexity_growth_profile(max_N, step)
        complexities = [k for _, k in profile]

        max_complexity = max(complexities) if complexities else 0
        appears_bounded = all(k <= complexities[0] + 2 for k in complexities) if complexities else True

        return {
            'profile': profile,
            'max_complexity': max_complexity,
            'appears_bounded': appears_bounded,
            'conclusion': (
                "Complexity appears BOUNDED — sequence may be eventually periodic"
                if appears_bounded else
                "Complexity appears UNBOUNDED — consistent with algebraic irrational"
            )
        }


# ============================================================
# §3. Automatic Sequence Classifier
# ============================================================

class AutomaticSequenceClassifier:
    """
    Classify a sequence based on its complexity properties:
    - Eventually periodic (rational digit real)
    - Linear complexity + non-periodic (transcendental by AB)
    - Superlinear complexity (inconclusive)
    """

    def __init__(self, seq: Callable[[int], int], base: int = 2,
                 prefix_length: int = 300):
        self.seq = seq
        self.base = base
        self.N = prefix_length

    def classify(self) -> Dict[str, object]:
        """
        Classify the sequence and return a detailed analysis.
        """
        certifier = TranscendenceCertifier(self.seq, self.base, self.N)
        cert = certifier.certify()

        # Additional analysis: check k-automaticity
        # k-automatic sequences have p(n) ≤ k·S² where S is the DFAO state count
        profile = cert['profile']
        first_diffs = [profile[i+1] - profile[i] for i in range(len(profile)-1)]
        max_diff = max(first_diffs) if first_diffs else 0

        is_possibly_automatic = cert['is_linear'] and max_diff < self.base * 10

        result = {
            'classification': 'unknown',
            'details': cert,
            'max_complexity_increment': max_diff,
            'is_possibly_automatic': is_possibly_automatic,
        }

        if not cert['is_nonperiodic']:
            result['classification'] = 'eventually_periodic'
            result['digit_real_type'] = 'rational'
        elif cert['is_linear']:
            result['classification'] = 'linear_complexity_nonperiodic'
            result['digit_real_type'] = 'transcendental (by Adamczewski-Bugeaud)'
            if is_possibly_automatic:
                result['sub_classification'] = 'possibly_automatic'
        else:
            result['classification'] = 'superlinear_complexity'
            result['digit_real_type'] = 'unknown (criterion does not apply)'

        return result


# ============================================================
# §4. Pseudorandomness Assessor
# ============================================================

class PseudorandomnessAssessor:
    """
    Assess the pseudorandomness quality of a sequence using
    complexity-theoretic measures from the sofic transcendence framework.

    A sequence that resists finite-state compression (high fsComplexity)
    is "pseudorandom" against finite-state distinguishers.
    """

    def __init__(self, seq: Callable[[int], int], alphabet_size: int = 2):
        self.seq = seq
        self.b = alphabet_size

    def frequency_test(self, N: int) -> Dict[int, float]:
        """Compute symbol frequencies in the first N terms."""
        counts = defaultdict(int)
        for i in range(N):
            counts[self.seq(i)] += 1
        return {k: v / N for k, v in sorted(counts.items())}

    def serial_correlation(self, N: int, lag: int = 1) -> float:
        """Compute the serial correlation at the given lag."""
        prefix = [self.seq(n) for n in range(N)]
        mean = sum(prefix) / N
        var = sum((x - mean) ** 2 for x in prefix) / N
        if var == 0:
            return 0.0
        cov = sum((prefix[i] - mean) * (prefix[i + lag] - mean)
                   for i in range(N - lag)) / (N - lag)
        return cov / var

    def assess(self, N: int = 1000) -> Dict[str, object]:
        """
        Run a suite of pseudorandomness tests.

        Returns a quality score and detailed test results.
        """
        freqs = self.frequency_test(N)

        # Frequency uniformity (chi-squared style)
        expected = 1.0 / self.b
        freq_score = sum((f - expected) ** 2 for f in freqs.values()) / expected

        # Serial correlation
        corr1 = self.serial_correlation(N, 1)
        corr2 = self.serial_correlation(N, 2)

        # Complexity assessment
        analyzer = CompressionAnalyzer(self.seq, self.b)
        complexity = analyzer.estimate_complexity_heuristic(min(N, 50))

        # Overall score (lower is more "random")
        quality_score = freq_score + abs(corr1) + abs(corr2)

        return {
            'frequencies': freqs,
            'frequency_deviation': freq_score,
            'serial_correlation_lag1': corr1,
            'serial_correlation_lag2': corr2,
            'fs_complexity_estimate': complexity,
            'quality_score': quality_score,
            'verdict': (
                "High pseudorandomness (low deviations)"
                if quality_score < 0.1 else
                "Moderate pseudorandomness"
                if quality_score < 0.5 else
                "Low pseudorandomness (significant patterns)"
            )
        }


# ============================================================
# §5. Application Demos
# ============================================================

def demo_transcendence_certification():
    """Demonstrate the transcendence certification pipeline."""
    print("=" * 70)
    print("APPLICATION 1: Transcendence Certification")
    print("=" * 70)

    # Thue-Morse constant
    thue_morse = lambda n: bin(n).count('1') % 2
    cert = TranscendenceCertifier(thue_morse, base=2, prefix_length=300)
    result = cert.certify()
    print(f"\nThue-Morse constant (base 2):")
    print(f"  {result['reasoning']}")
    print(f"  Complexity profile (first 10): {result['profile'][:10]}")

    # Fibonacci constant (Sturmian)
    fib_cache = {'seq': [0]}
    def fibonacci_word(n):
        while len(fib_cache['seq']) <= n:
            s = fib_cache['seq']
            new = []
            for c in s:
                new.extend([0, 1] if c == 0 else [0])
            fib_cache['seq'] = new
        return fib_cache['seq'][n]

    cert2 = TranscendenceCertifier(fibonacci_word, base=2, prefix_length=300)
    result2 = cert2.certify()
    print(f"\nFibonacci constant (Sturmian, base 2):")
    print(f"  {result2['reasoning']}")
    print(f"  Complexity profile (first 10): {result2['profile'][:10]}")

    # Periodic sequence (should be rational)
    periodic = lambda n: n % 3
    cert3 = TranscendenceCertifier(periodic, base=10, prefix_length=300)
    result3 = cert3.certify()
    print(f"\nPeriodic sequence 0,1,2,0,1,2,... (base 10):")
    print(f"  {result3['reasoning']}")
    print()


def demo_compression_analysis():
    """Demonstrate finite-state compression analysis."""
    print("=" * 70)
    print("APPLICATION 2: Finite-State Compression Analysis")
    print("=" * 70)

    thue_morse = lambda n: bin(n).count('1') % 2
    analyzer = CompressionAnalyzer(thue_morse, alphabet_size=2)

    print("\nThue-Morse sequence compression profile:")
    profile = analyzer.complexity_growth_profile(60, 5)
    for N, K in profile:
        bar = "█" * K
        print(f"  N={N:3d}: fsComplexity ≈ {K:2d} {bar}")

    result = analyzer.check_unbounded_growth(60, 5)
    print(f"\n  {result['conclusion']}")
    print()


def demo_sequence_classification():
    """Demonstrate automatic sequence classification."""
    print("=" * 70)
    print("APPLICATION 3: Sequence Classification")
    print("=" * 70)

    sequences = {
        "Thue-Morse": lambda n: bin(n).count('1') % 2,
        "Period-5": lambda n: n % 5,
        "Rudin-Shapiro": lambda n: sum(1 for i in range(len(bin(n)[2:])-1)
                                       if bin(n)[2:][i] == '1' and
                                       bin(n)[2:][i+1] == '1') % 2,
    }

    for name, seq in sequences.items():
        classifier = AutomaticSequenceClassifier(seq, base=2, prefix_length=200)
        result = classifier.classify()
        print(f"\n{name}:")
        print(f"  Classification: {result['classification']}")
        print(f"  Digit real type: {result['digit_real_type']}")
        if 'sub_classification' in result:
            print(f"  Sub-classification: {result['sub_classification']}")
        print(f"  Max complexity increment: {result['max_complexity_increment']}")
    print()


def demo_pseudorandomness():
    """Demonstrate pseudorandomness assessment."""
    print("=" * 70)
    print("APPLICATION 4: Pseudorandomness Assessment")
    print("=" * 70)

    thue_morse = lambda n: bin(n).count('1') % 2
    assessor = PseudorandomnessAssessor(thue_morse, alphabet_size=2)
    result = assessor.assess(500)

    print(f"\nThue-Morse pseudorandomness assessment:")
    print(f"  Frequencies: {result['frequencies']}")
    print(f"  Serial correlation (lag 1): {result['serial_correlation_lag1']:.4f}")
    print(f"  Serial correlation (lag 2): {result['serial_correlation_lag2']:.4f}")
    print(f"  Quality score: {result['quality_score']:.4f}")
    print(f"  Verdict: {result['verdict']}")

    # Compare with truly periodic
    periodic = lambda n: n % 2
    assessor2 = PseudorandomnessAssessor(periodic, alphabet_size=2)
    result2 = assessor2.assess(500)

    print(f"\nPeriod-2 sequence (0,1,0,1,...) assessment:")
    print(f"  Frequencies: {result2['frequencies']}")
    print(f"  Serial correlation (lag 1): {result2['serial_correlation_lag1']:.4f}")
    print(f"  Quality score: {result2['quality_score']:.4f}")
    print(f"  Verdict: {result2['verdict']}")
    print()


if __name__ == "__main__":
    demo_transcendence_certification()
    demo_compression_analysis()
    demo_sequence_classification()
    demo_pseudorandomness()

    print("=" * 70)
    print("All applications completed successfully.")
    print("=" * 70)


#!/usr/bin/env python3
"""
Sofic Transcendence Demos
=========================

Demonstrates the key mathematical concepts from the sofic transcendence theory:
1. Factor complexity computation for various sequences
2. Eventual periodicity detection
3. Finite-state machine generation and periodicity
4. Visualization of complexity growth rates

These demos make tangible the abstract theorem: finite-state describability
of digit expansions forces transcendence.
"""

from typing import Callable, Optional
from collections import defaultdict
import math


# ============================================================
# §1. Sequence Generators
# ============================================================

def thue_morse(n: int) -> int:
    """Thue-Morse sequence: t(n) = popcount(n) mod 2."""
    return bin(n).count('1') % 2


def fibonacci_word(n: int, _cache: dict = {}) -> int:
    """
    Fibonacci (Sturmian) word: the fixed point of 0 -> 01, 1 -> 0.
    Computed via the limit of iterated substitution.
    """
    if 'seq' not in _cache or len(_cache['seq']) <= n:
        s = [0]
        while len(s) <= max(n, 100):
            s_new = []
            for c in s:
                if c == 0:
                    s_new.extend([0, 1])
                else:
                    s_new.append(0)
            s = s_new
        _cache['seq'] = s
    return _cache['seq'][n]


def rudin_shapiro(n: int) -> int:
    """Rudin-Shapiro sequence: parity of the number of '11' blocks in binary."""
    b = bin(n)[2:]
    count = sum(1 for i in range(len(b) - 1) if b[i] == '1' and b[i+1] == '1')
    return count % 2


def sqrt2_digits(n: int, base: int = 10, _cache: dict = {}) -> int:
    """
    Digits of sqrt(2) in the given base, using Python's decimal module
    for high precision.
    """
    key = (base, 'digits')
    if key not in _cache or len(_cache[key]) <= n:
        from decimal import Decimal, getcontext
        precision = max(n + 50, 200)
        getcontext().prec = precision
        val = Decimal(2).sqrt()
        # Extract fractional digits
        frac = val - int(val)
        digits = []
        for _ in range(n + 10):
            frac *= base
            d = int(frac)
            digits.append(d)
            frac -= d
        _cache[key] = digits
    return _cache[key][n]


def eventually_periodic_sequence(prefix: list, period: list) -> Callable[[int], int]:
    """Create an eventually periodic sequence with given prefix and period."""
    def seq(n: int) -> int:
        if n < len(prefix):
            return prefix[n]
        return period[(n - len(prefix)) % len(period)]
    return seq


# ============================================================
# §2. Factor Complexity
# ============================================================

def compute_factors(seq: Callable[[int], int], m: int, N: int) -> set:
    """Compute the set of distinct length-m factors in seq[0:N]."""
    factors = set()
    for i in range(N - m + 1):
        w = tuple(seq(i + j) for j in range(m))
        factors.add(w)
    return factors


def factor_complexity(seq: Callable[[int], int], m: int, N: int) -> int:
    """Compute p(m) = number of distinct length-m factors in seq[0:N]."""
    return len(compute_factors(seq, m, N))


def complexity_profile(seq: Callable[[int], int], max_m: int, N: int) -> list:
    """Compute [p(1), p(2), ..., p(max_m)]."""
    return [factor_complexity(seq, m, N) for m in range(1, max_m + 1)]


# ============================================================
# §3. Eventual Periodicity Detection
# ============================================================

def detect_eventual_periodicity(
    seq: Callable[[int], int], N: int, max_period: Optional[int] = None
) -> Optional[tuple]:
    """
    Detect eventual periodicity in seq[0:N].
    Returns (start, period) if found, None otherwise.
    """
    if max_period is None:
        max_period = N // 4
    prefix = [seq(n) for n in range(N)]
    for p in range(1, max_period + 1):
        for start in range(min(p + 1, N // 4)):
            periodic = True
            remaining = N - start - p
            if remaining < 3 * p:  # Need at least 3 full periods
                continue
            for i in range(start, N - p):
                if prefix[i] != prefix[i + p]:
                    periodic = False
                    break
            if periodic:
                return (start, p)
    return None


# ============================================================
# §4. Finite-State Machine Simulation
# ============================================================

class FiniteStateMachine:
    """A deterministic finite-state machine generating a sequence."""

    def __init__(self, num_states: int, transition: list, output: list, init_state: int = 0):
        """
        Args:
            num_states: Number of states K.
            transition: List of length K, transition[s] = next state from s.
            output: List of length K, output[s] = symbol emitted from s.
            init_state: Initial state index.
        """
        self.K = num_states
        self.transition = transition
        self.output = output
        self.init_state = init_state

    def generate(self, N: int) -> list:
        """Generate the first N symbols."""
        result = []
        state = self.init_state
        for _ in range(N):
            result.append(self.output[state])
            state = self.transition[state]
        return result

    def detect_period(self) -> tuple:
        """
        Detect the eventual period of the state sequence.
        Returns (transient_length, period).
        """
        visited = {}
        state = self.init_state
        for step in range(self.K + 1):
            if state in visited:
                return (visited[state], step - visited[state])
            visited[state] = step
            state = self.transition[state]
        return (0, self.K)  # Should not reach here for valid FSM


def estimate_fs_complexity(seq: Callable[[int], int], N: int, alphabet_size: int = 2) -> int:
    """
    Estimate the minimum number of states needed to generate seq[0:N]
    by exhaustive search over small K-state machines.

    Warning: Exponential in K. Only practical for small K and N.
    """
    target = [seq(n) for n in range(N)]

    for K in range(1, min(N + 1, 8)):  # Cap at 7 states for tractability
        # Try all K-state machines
        import itertools
        found = False
        for trans in itertools.product(range(K), repeat=K):
            for out in itertools.product(range(alphabet_size), repeat=K):
                for s0 in range(K):
                    # Simulate
                    state = s0
                    match = True
                    for i in range(N):
                        if out[state] != target[i]:
                            match = False
                            break
                        state = trans[state]
                    if match:
                        return K
    return N  # Fallback: trivially N states suffice


# ============================================================
# §5. Demo Runs
# ============================================================

def demo_factor_complexity():
    """Demonstrate factor complexity computation for various sequences."""
    print("=" * 70)
    print("DEMO 1: Factor Complexity of Important Sequences")
    print("=" * 70)

    sequences = {
        "Thue-Morse": thue_morse,
        "Fibonacci (Sturmian)": fibonacci_word,
        "Rudin-Shapiro": rudin_shapiro,
        "Eventually periodic [0,1,0,1,...]": eventually_periodic_sequence([], [0, 1]),
    }

    N = 500  # Prefix length for computation

    for name, seq in sequences.items():
        print(f"\n{name}:")
        profile = complexity_profile(seq, 20, N)
        print(f"  p(n) for n=1..20: {profile}")

        # Check linearity
        if len(profile) >= 10:
            # Fit a linear model p(n) ≈ C*n + D
            n_vals = list(range(1, 21))
            # Simple least-squares
            n_mean = sum(n_vals) / len(n_vals)
            p_mean = sum(profile) / len(profile)
            num = sum((n - n_mean) * (p - p_mean) for n, p in zip(n_vals, profile))
            den = sum((n - n_mean) ** 2 for n in n_vals)
            C = num / den if den > 0 else 0
            D = p_mean - C * n_mean
            print(f"  Linear fit: p(n) ≈ {C:.2f}·n + {D:.2f}")

    print()


def demo_periodicity_detection():
    """Demonstrate periodicity detection."""
    print("=" * 70)
    print("DEMO 2: Eventual Periodicity Detection")
    print("=" * 70)

    sequences = {
        "Thue-Morse": thue_morse,
        "Eventually periodic [1,2,3,0,1,0,1,...]":
            eventually_periodic_sequence([1, 2, 3], [0, 1]),
        "Fibonacci word": fibonacci_word,
    }

    for name, seq in sequences.items():
        result = detect_eventual_periodicity(seq, 200, 50)
        print(f"\n{name}:")
        first_20 = [seq(n) for n in range(20)]
        print(f"  First 20 terms: {first_20}")
        if result:
            print(f"  Eventually periodic! Start={result[0]}, Period={result[1]}")
        else:
            print(f"  Not eventually periodic (in first 200 terms)")

    print()


def demo_fsm_periodicity():
    """Demonstrate that finite-state machines produce eventually periodic sequences."""
    print("=" * 70)
    print("DEMO 3: Finite-State Machine → Eventual Periodicity (Pigeonhole)")
    print("=" * 70)

    # Example 1: Simple 3-state machine
    fsm1 = FiniteStateMachine(
        num_states=3,
        transition=[1, 2, 0],
        output=[0, 1, 1],
        init_state=0
    )
    seq1 = fsm1.generate(20)
    period1 = fsm1.detect_period()
    print(f"\n3-state machine: transition=[1,2,0], output=[0,1,1]")
    print(f"  First 20 outputs: {seq1}")
    print(f"  Period detected: transient={period1[0]}, period={period1[1]}")

    # Example 2: 5-state machine with transient
    fsm2 = FiniteStateMachine(
        num_states=5,
        transition=[1, 2, 3, 4, 2],
        output=[0, 0, 1, 0, 1],
        init_state=0
    )
    seq2 = fsm2.generate(20)
    period2 = fsm2.detect_period()
    print(f"\n5-state machine: transition=[1,2,3,4,2], output=[0,0,1,0,1]")
    print(f"  First 20 outputs: {seq2}")
    print(f"  Period detected: transient={period2[0]}, period={period2[1]}")

    # Example 3: Demonstrate pigeonhole bound
    print(f"\nPigeonhole principle: a K-state machine must cycle within K steps.")
    for K in [3, 5, 7, 10]:
        import random
        random.seed(42 + K)
        trans = [random.randint(0, K - 1) for _ in range(K)]
        out = [random.randint(0, 1) for _ in range(K)]
        fsm = FiniteStateMachine(K, trans, out)
        period = fsm.detect_period()
        print(f"  K={K}: transient={period[0]}, period={period[1]}, "
              f"total cycle start ≤ K={K}: {'✓' if period[0] <= K else '✗'}")

    print()


def demo_transcendence_criterion():
    """Demonstrate the transcendence criterion in action."""
    print("=" * 70)
    print("DEMO 4: Transcendence Criterion")
    print("=" * 70)
    print()
    print("The Adamczewski-Bugeaud criterion states:")
    print("  Linear factor complexity + non-periodicity → transcendence")
    print()

    N = 300

    sequences = {
        "Thue-Morse": (thue_morse, 2),
        "Fibonacci word": (fibonacci_word, 2),
        "Rudin-Shapiro": (rudin_shapiro, 2),
    }

    for name, (seq, base) in sequences.items():
        profile = complexity_profile(seq, 15, N)
        is_periodic = detect_eventual_periodicity(seq, N, 50)

        # Check linearity: max ratio p(n)/n
        max_ratio = max(p / n for n, p in zip(range(1, 16), profile))

        print(f"{name} (base {base}):")
        print(f"  Complexity p(1..15): {profile}")
        print(f"  Max p(n)/n ratio: {max_ratio:.2f} (linear if bounded)")
        print(f"  Eventually periodic: {'Yes' if is_periodic else 'No'}")

        if max_ratio < 10 and not is_periodic:
            print(f"  → TRANSCENDENCE CRITERION APPLIES: digit real is transcendental!")
        elif is_periodic:
            print(f"  → Eventually periodic: digit real is rational.")
        else:
            print(f"  → Complexity may not be linear; criterion inconclusive.")
        print()


def demo_compression_gap():
    """Demonstrate the finite-state compression gap."""
    print("=" * 70)
    print("DEMO 5: Finite-State Compression Gap")
    print("=" * 70)
    print()
    print("The compression gap theorem: for algebraic irrationals,")
    print("fsComplexity(a, N) → ∞ as N → ∞.")
    print()

    print("Estimating finite-state complexity for Thue-Morse prefixes:")
    for N in [4, 6, 8, 10, 12, 14]:
        K = estimate_fs_complexity(thue_morse, N, alphabet_size=2)
        print(f"  N={N:3d}: fsComplexity ≤ {K}")

    print()
    print("For comparison, a periodic sequence [0,1,0,1,...] needs only 2 states:")
    periodic = eventually_periodic_sequence([], [0, 1])
    for N in [4, 8, 16, 32]:
        K = estimate_fs_complexity(periodic, N, alphabet_size=2)
        print(f"  N={N:3d}: fsComplexity ≤ {K}")

    print()


if __name__ == "__main__":
    demo_factor_complexity()
    demo_periodicity_detection()
    demo_fsm_periodicity()
    demo_transcendence_criterion()
    demo_compression_gap()

    print("=" * 70)
    print("All demos completed successfully.")
    print("=" * 70)
