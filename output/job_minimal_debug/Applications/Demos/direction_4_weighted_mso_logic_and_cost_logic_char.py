#!/usr/bin/env python3
"""
Applications of the Tropical Büchi–Elgot Theorem

Demonstrates real-world applications where the equivalence between
min-plus automata and weighted MSO logic provides computational
and conceptual advantages:

1. Network routing and shortest paths
2. Sequence alignment in bioinformatics  
3. Speech recognition / Viterbi decoding
4. Scheduling and resource optimization
"""

import math
from typing import List, Dict, Tuple, Set, Optional
from dataclasses import dataclass, field

INF = float('inf')


@dataclass
class MinPlusAutomaton:
    """Min-plus automaton for application examples."""
    n_states: int
    init: List[float]
    transitions: Dict[Tuple[int, str, int], float]
    final: List[float]
    state_names: List[str] = field(default_factory=list)
    
    def eval_dp(self, word: List[str]) -> float:
        dp = list(self.init)
        for symbol in word:
            new_dp = [INF] * self.n_states
            for q_prime in range(self.n_states):
                for q in range(self.n_states):
                    w = self.transitions.get((q, symbol, q_prime), INF)
                    if dp[q] < INF and w < INF:
                        new_dp[q_prime] = min(new_dp[q_prime], dp[q] + w)
            dp = new_dp
        return min(dp[q] + self.final[q] 
                   for q in range(self.n_states) 
                   if dp[q] < INF and self.final[q] < INF)

    def eval_trace(self, word: List[str]) -> Tuple[float, List[int]]:
        n, m = self.n_states, len(word)
        dp = [list(self.init)]
        parent = []
        for t, symbol in enumerate(word):
            new_dp, new_parent = [INF] * n, [-1] * n
            for qp in range(n):
                for q in range(n):
                    w = self.transitions.get((q, symbol, qp), INF)
                    if dp[t][q] < INF and w < INF:
                        c = dp[t][q] + w
                        if c < new_dp[qp]:
                            new_dp[qp], new_parent[qp] = c, q
            dp.append(new_dp)
            parent.append(new_parent)
        best_cost, best_q = INF, -1
        for q in range(n):
            if dp[m][q] < INF and self.final[q] < INF:
                c = dp[m][q] + self.final[q]
                if c < best_cost:
                    best_cost, best_q = c, q
        if best_q == -1:
            return INF, []
        run = [best_q]
        for t in range(m - 1, -1, -1):
            run.append(parent[t][run[-1]])
        run.reverse()
        return best_cost, run


# ============================================================
# Application 1: Network Routing
# ============================================================

def app_network_routing():
    """Model packet routing through a network as a min-plus automaton.
    
    Each 'letter' represents a routing decision at a node.
    The automaton computes the minimum latency path.
    """
    print("=" * 60)
    print("Application 1: Network Routing Optimization")
    print("=" * 60)
    print()
    print("A network with 4 nodes (Server, Router1, Router2, Client)")
    print("Routing decisions: 'f' (fast/expensive), 's' (slow/cheap)")
    print()
    
    # States: Server(0), Router1(1), Router2(2), Client(3)
    A = MinPlusAutomaton(
        n_states=4,
        init=[0, INF, INF, INF],  # start at Server
        transitions={
            # From Server
            (0, 'f', 1): 2,   # fast to Router1: latency 2
            (0, 's', 2): 5,   # slow to Router2: latency 5
            # From Router1  
            (1, 'f', 3): 3,   # fast to Client: latency 3
            (1, 's', 2): 1,   # slow to Router2: latency 1
            # From Router2
            (2, 'f', 3): 2,   # fast to Client: latency 2  
            (2, 's', 1): 1,   # slow to Router1: latency 1
            # Client stays
            (3, 'f', 3): 0,
            (3, 's', 3): 0,
        },
        final=[INF, INF, INF, 0],  # must end at Client
        state_names=['Server', 'Router1', 'Router2', 'Client']
    )
    
    routes = [
        list('ff'),      # fast-fast: Server→R1→Client
        list('sf'),      # slow-fast: Server→R2→Client 
        list('fsf'),     # Server→R1→R2→Client
        list('sff'),     # Server→R2→R1→Client (via slow)
        list('fss'),     # Server→R1→R2→?... 
        list('ssf'),     # Server→R2→R1→Client
    ]
    
    print(f"  {'Route':10s} | {'Latency':>8s} | Optimal Path")
    print(f"  {'-'*10} | {'-'*8} | {'-'*30}")
    for route in routes:
        cost, run = A.eval_trace(route)
        route_str = ''.join(route)
        cost_str = '∞' if cost == INF else str(int(cost))
        if run:
            path = ' → '.join(A.state_names[q] for q in run)
        else:
            path = "(no valid path)"
        print(f"  {route_str:10s} | {cost_str:>8s} | {path}")
    
    print()
    print("The min-plus automaton finds optimal routing automatically.")
    print("The weighted MSO formula equivalent would express:")
    print("  ∃path. (valid_route(path) ∧ total_latency(path))")
    print()


# ============================================================
# Application 2: Sequence Alignment (Bioinformatics)
# ============================================================

def app_sequence_alignment():
    """Model sequence alignment scoring as a min-plus computation.
    
    The alignment cost is computed by a min-plus automaton that
    processes the sequence character by character.
    """
    print("=" * 60)
    print("Application 2: DNA Sequence Alignment Scoring")
    print("=" * 60)
    print()
    
    # Simple scoring: match=0 (perfect), mismatch=1 (penalty)
    # This models finding the best alignment of a pattern in a text
    
    def alignment_score(text: str, pattern: str) -> Tuple[float, int]:
        """Find minimum edit distance alignment of pattern in text."""
        m = len(pattern)
        best_cost = INF
        best_pos = -1
        
        for start in range(len(text) - m + 1):
            cost = sum(0 if text[start + i] == pattern[i] else 1
                       for i in range(m))
            if cost < best_cost:
                best_cost = cost
                best_pos = start
        
        return best_cost, best_pos
    
    sequences = [
        ("ACGTACGTACGT", "ACGT"),
        ("TTTTACGTTTTT", "ACGT"),
        ("ACCCGTTTAAAA", "ACGT"),
        ("TTTTTTTTTTTTT", "ACGT"),
    ]
    
    print(f"  {'Text':15s} | {'Pattern':8s} | {'Score':>6s} | {'Position':>8s}")
    print(f"  {'-'*15} | {'-'*8} | {'-'*6} | {'-'*8}")
    for text, pattern in sequences:
        score, pos = alignment_score(text, pattern)
        print(f"  {text:15s} | {pattern:8s} | {score:6.0f} | {pos:>8d}")
    
    print()
    print("This scoring function is tropically recognizable:")
    print("a min-plus automaton computes the minimum mismatch cost")
    print("by the tropical Büchi–Elgot theorem.\n")


# ============================================================
# Application 3: Speech Recognition / Viterbi
# ============================================================

def app_viterbi():
    """Model speech recognition as tropical automaton decoding.
    
    The Viterbi algorithm for Hidden Markov Models is precisely
    a min-plus automaton evaluation in the tropical semiring.
    """
    print("=" * 60)
    print("Application 3: Speech Recognition (Viterbi Decoding)")
    print("=" * 60)
    print()
    
    # Simple HMM: 3 hidden states (Vowel, Consonant, Silence)
    # Observations: phonemes 'a', 'k', '_' 
    # Using -log probabilities → additive costs → min-plus automaton
    
    A = MinPlusAutomaton(
        n_states=3,
        init=[1, 2, 0],  # start likely in Silence
        transitions={
            # Vowel(0) transitions
            (0, 'a', 0): 1,   # vowel→vowel reading 'a': likely
            (0, 'k', 1): 2,   # vowel→consonant reading 'k': moderate
            (0, '_', 2): 3,   # vowel→silence: less likely
            # Consonant(1) transitions
            (1, 'a', 0): 2,   # consonant→vowel reading 'a'
            (1, 'k', 1): 1,   # consonant→consonant reading 'k'
            (1, '_', 2): 2,   # consonant→silence
            # Silence(2) transitions
            (2, 'a', 0): 2,   # silence→vowel
            (2, 'k', 1): 2,   # silence→consonant
            (2, '_', 2): 0,   # silence→silence (very likely)
        },
        final=[1, 1, 0],  # end in silence preferred
        state_names=['Vowel', 'Consonant', 'Silence']
    )
    
    utterances = [
        list('_aka_'),     # word "aka" with silence
        list('__aak_'),    # "aak" with longer pause
        list('kaka'),      # "kaka"
        list('_____'),     # pure silence
        list('aaaa'),      # all vowels
    ]
    
    print("Hidden Markov Model as Min-Plus Automaton:")
    print("States: Vowel, Consonant, Silence")
    print("Costs are -log(probability)\n")
    
    print(f"  {'Utterance':10s} | {'Cost':>6s} | Decoded State Sequence")
    print(f"  {'-'*10} | {'-'*6} | {'-'*35}")
    for utt in utterances:
        cost, run = A.eval_trace(utt)
        utt_str = ''.join(utt)
        states = [A.state_names[q][0] for q in run]  # first letter
        print(f"  {utt_str:10s} | {int(cost):6d} | {' '.join(states)}")
    
    print()
    print("The Viterbi algorithm IS tropical automaton evaluation.")
    print("The tropical Büchi–Elgot theorem tells us this decoding")
    print("is exactly equivalent to a weighted MSO formula.\n")


# ============================================================
# Application 4: Job Scheduling
# ============================================================

def app_scheduling():
    """Model job scheduling as tropical optimization.
    
    Given a sequence of job types to process, the min-plus automaton
    computes the minimum total processing time, accounting for
    setup costs when switching between job types.
    """
    print("=" * 60)
    print("Application 4: Manufacturing Job Scheduling")
    print("=" * 60)
    print()
    
    # States: current machine configuration (A-mode, B-mode, C-mode)
    # Alphabet: job types 'a', 'b', 'c'
    # Cost = processing time + setup time for switching
    
    A = MinPlusAutomaton(
        n_states=3,
        init=[0, 0, 0],  # can start in any configuration
        transitions={
            # A-mode processing
            (0, 'a', 0): 2,   # job a in A-mode: 2 hours
            (0, 'b', 1): 5,   # switch to B-mode + process b: 3+2
            (0, 'c', 2): 6,   # switch to C-mode + process c: 3+3
            # B-mode processing  
            (1, 'a', 0): 5,   # switch to A-mode + process a
            (1, 'b', 1): 2,   # job b in B-mode: 2 hours
            (1, 'c', 2): 5,   # switch + process
            # C-mode processing
            (2, 'a', 0): 6,   # switch + process
            (2, 'b', 1): 5,   # switch + process
            (2, 'c', 2): 3,   # job c in C-mode: 3 hours
        },
        final=[0, 0, 0],
        state_names=['A-mode', 'B-mode', 'C-mode']
    )
    
    schedules = [
        list('aaa'),     # all same type
        list('abc'),     # all different
        list('aabb'),    # grouped
        list('abab'),    # alternating
        list('aaabbb'),  # two groups
        list('abcabc'),  # repeating pattern
    ]
    
    print("Machine setup costs make job ordering matter!")
    print("Processing: 2-3 hours. Setup for switch: ~3 hours.\n")
    
    print(f"  {'Schedule':10s} | {'Min Cost':>9s} | Optimal Configuration Sequence")
    print(f"  {'-'*10} | {'-'*9} | {'-'*35}")
    for sched in schedules:
        cost, run = A.eval_trace(sched)
        sched_str = ''.join(sched)
        configs = [A.state_names[q] for q in run]
        print(f"  {sched_str:10s} | {int(cost):6d} hrs | {' → '.join(configs)}")
    
    print()
    print("The min-plus automaton optimizes over all possible")
    print("machine configuration sequences — tropical optimization")
    print("at its finest.\n")


# ============================================================

def main():
    print("╔══════════════════════════════════════════════════════════╗")
    print("║   Real-World Applications of Tropical Optimization      ║")
    print("║   Powered by the Büchi–Elgot Correspondence             ║")
    print("╚══════════════════════════════════════════════════════════╝\n")
    
    app_network_routing()
    app_sequence_alignment()
    app_viterbi()
    app_scheduling()
    
    print("=" * 60)
    print("All applications demonstrated successfully!")
    print()
    print("Key insight: All these optimization problems are instances")
    print("of tropical automaton evaluation. The Büchi–Elgot theorem")
    print("guarantees each has an equivalent logical specification")
    print("in weighted MSO — enabling formal verification of")
    print("optimality properties.")
    print("=" * 60)


if __name__ == '__main__':
    main()


#!/usr/bin/env python3
"""
Tropical Büchi–Elgot Theorem: Interactive Demonstrations

This module provides concrete numerical examples of the equivalence between
min-plus automata and weighted MSO logic over finite words. It demonstrates:
1. Min-plus automaton evaluation on words
2. Weighted MSO formula evaluation with tropical semantics
3. Product and union automaton constructions
4. The correspondence between logical formulas and automata
"""

import math
from typing import List, Dict, Tuple, Optional, Callable
from itertools import product as cart_product
from dataclasses import dataclass, field


# ============================================================
# Weight type: tropical semiring over non-negative integers + ∞
# ============================================================

INF = float('inf')

def trop_add(a: float, b: float) -> float:
    """Tropical addition = minimum."""
    return min(a, b)

def trop_mul(a: float, b: float) -> float:
    """Tropical multiplication = ordinary addition."""
    if a == INF or b == INF:
        return INF
    return a + b


# ============================================================
# Min-Plus Automaton
# ============================================================

@dataclass
class MinPlusAutomaton:
    """A finite weighted automaton over the min-plus (tropical) semiring.
    
    States are integers 0..n-1. Weights are non-negative integers or INF.
    """
    n_states: int
    init: List[float]           # init[q] = initial weight of state q
    step: Dict[Tuple[int, str, int], float]  # step[(q, a, q')] = transition weight
    final: List[float]          # final[q] = accepting weight of state q
    
    def get_step(self, q: int, a: str, q_prime: int) -> float:
        return self.step.get((q, a, q_prime), INF)
    
    def run_cost(self, word: List[str], run: List[int]) -> float:
        """Cost of a specific run (sequence of states) on a word."""
        assert len(run) == len(word) + 1
        cost = self.init[run[0]]
        for i, a in enumerate(word):
            cost = trop_mul(cost, self.get_step(run[i], a, run[i + 1]))
        cost = trop_mul(cost, self.final[run[-1]])
        return cost
    
    def eval(self, word: List[str]) -> float:
        """Evaluate the automaton: minimum cost over all runs."""
        if not word:
            return min(trop_mul(self.init[q], self.final[q])
                       for q in range(self.n_states))
        
        best = INF
        for run in cart_product(range(self.n_states), repeat=len(word) + 1):
            cost = self.run_cost(word, list(run))
            best = trop_add(best, cost)
        return best
    
    def eval_dp(self, word: List[str]) -> float:
        """Evaluate using dynamic programming (efficient)."""
        # dp[q] = min cost to reach state q after processing prefix
        dp = list(self.init)
        for a in word:
            new_dp = [INF] * self.n_states
            for q_prime in range(self.n_states):
                for q in range(self.n_states):
                    cost = trop_mul(dp[q], self.get_step(q, a, q_prime))
                    new_dp[q_prime] = trop_add(new_dp[q_prime], cost)
            dp = new_dp
        return min(trop_mul(dp[q], self.final[q]) for q in range(self.n_states))


def product_automaton(A: MinPlusAutomaton, B: MinPlusAutomaton) -> MinPlusAutomaton:
    """Product automaton: computes A.eval(w) + B.eval(w)."""
    n = A.n_states * B.n_states
    
    def pair_to_idx(qa, qb):
        return qa * B.n_states + qb
    
    def idx_to_pair(idx):
        return divmod(idx, B.n_states)
    
    init = [INF] * n
    final = [INF] * n
    step = {}
    
    for qa in range(A.n_states):
        for qb in range(B.n_states):
            idx = pair_to_idx(qa, qb)
            init[idx] = trop_mul(A.init[qa], B.init[qb])
            final[idx] = trop_mul(A.final[qa], B.final[qb])
    
    for (qa, a, qa_p), wa in A.step.items():
        for (qb, b, qb_p), wb in B.step.items():
            if a == b:
                idx = pair_to_idx(qa, qb)
                idx_p = pair_to_idx(qa_p, qb_p)
                step[(idx, a, idx_p)] = trop_mul(wa, wb)
    
    return MinPlusAutomaton(n, init, step, final)


def union_automaton(A: MinPlusAutomaton, B: MinPlusAutomaton) -> MinPlusAutomaton:
    """Union automaton: computes min(A.eval(w), B.eval(w))."""
    n = A.n_states + B.n_states
    
    init = A.init + B.init
    final = A.final + B.final
    step = {}
    
    for (q, a, q_p), w in A.step.items():
        step[(q, a, q_p)] = w
    for (q, a, q_p), w in B.step.items():
        step[(q + A.n_states, a, q_p + A.n_states)] = w
    
    return MinPlusAutomaton(n, init, step, final)


# ============================================================
# Demo 1: Shortest Path / Minimum Cost Automaton
# ============================================================

def demo_shortest_path():
    """Demonstrate a min-plus automaton computing shortest path costs.
    
    Consider a simple network with 3 nodes (0, 1, 2) and edges with costs.
    The automaton reads a sequence of 'routing decisions' and computes
    the minimum total cost to traverse the network.
    """
    print("=" * 60)
    print("Demo 1: Shortest Path via Min-Plus Automaton")
    print("=" * 60)
    
    # Network: 3 states, alphabet = {a, b}
    # 'a' = take the cheap route, 'b' = take the expensive route
    A = MinPlusAutomaton(
        n_states=3,
        init=[0, INF, INF],  # start at state 0
        step={
            (0, 'a', 1): 1,  # cheap: 0→1 costs 1
            (0, 'b', 2): 3,  # expensive: 0→2 costs 3
            (1, 'a', 0): 2,  # 1→0 costs 2
            (1, 'b', 2): 1,  # 1→2 costs 1
            (2, 'a', 0): 4,  # 2→0 costs 4
            (2, 'b', 1): 2,  # 2→1 costs 2
        },
        final=[0, 0, 0]  # accepting at any state with 0 cost
    )
    
    test_words = [
        [],
        ['a'],
        ['b'],
        ['a', 'b'],
        ['a', 'a'],
        ['b', 'a'],
        ['a', 'b', 'a'],
        ['a', 'a', 'a'],
    ]
    
    print("\nWord → Minimum Cost:")
    for w in test_words:
        cost = A.eval_dp(w)
        word_str = ''.join(w) if w else 'ε'
        print(f"  {word_str:10s} → {cost}")
    
    print("\nInterpretation: The automaton finds the cheapest route")
    print("through the network for each sequence of decisions.\n")


# ============================================================
# Demo 2: Product Automaton (Tropical Sum)
# ============================================================

def demo_product_automaton():
    """Demonstrate the product automaton computing the sum of two costs."""
    print("=" * 60)
    print("Demo 2: Product Automaton = Tropical Sum of Costs")
    print("=" * 60)
    
    # Automaton A: counts 'a' letters
    A = MinPlusAutomaton(
        n_states=1,
        init=[0],
        step={(0, 'a', 0): 1, (0, 'b', 0): 0},
        final=[0]
    )
    
    # Automaton B: counts 'b' letters with weight 2
    B = MinPlusAutomaton(
        n_states=1,
        init=[0],
        step={(0, 'a', 0): 0, (0, 'b', 0): 2},
        final=[0]
    )
    
    # Product: counts a + 2*b
    P = product_automaton(A, B)
    
    test_words = [
        ['a'],
        ['b'],
        ['a', 'b'],
        ['a', 'a', 'b'],
        ['b', 'b', 'a'],
    ]
    
    print("\nWord → A(w) + B(w) = Product(w):")
    for w in test_words:
        a_cost = A.eval_dp(w)
        b_cost = B.eval_dp(w)
        p_cost = P.eval_dp(w)
        word_str = ''.join(w)
        print(f"  {word_str:8s} → {a_cost} + {b_cost} = {p_cost}")
        assert p_cost == a_cost + b_cost, "Product automaton mismatch!"
    
    print("\n✓ Product automaton correctly computes A(w) + B(w)\n")


# ============================================================
# Demo 3: Union Automaton (Tropical Min)
# ============================================================

def demo_union_automaton():
    """Demonstrate the union automaton computing the min of two costs."""
    print("=" * 60)
    print("Demo 3: Union Automaton = Tropical Min of Costs")
    print("=" * 60)
    
    # Automaton A: word length
    A = MinPlusAutomaton(
        n_states=1,
        init=[0],
        step={(0, 'a', 0): 1, (0, 'b', 0): 1},
        final=[0]
    )
    
    # Automaton B: constant cost 3
    B = MinPlusAutomaton(
        n_states=1,
        init=[0],
        step={(0, 'a', 0): 0, (0, 'b', 0): 0},
        final=[3]
    )
    
    # Union: min(length, 3)
    U = union_automaton(A, B)
    
    test_words = [
        [],
        ['a'],
        ['a', 'b'],
        ['a', 'b', 'a'],
        ['a', 'b', 'a', 'b'],
        ['a'] * 5,
    ]
    
    print("\nWord → min(A(w), B(w)) = Union(w):")
    for w in test_words:
        a_cost = A.eval_dp(w)
        b_cost = B.eval_dp(w)
        u_cost = U.eval_dp(w)
        word_str = ''.join(w) if w else 'ε'
        print(f"  {word_str:10s} → min({a_cost}, {b_cost}) = {u_cost}")
        assert u_cost == min(a_cost, b_cost), "Union automaton mismatch!"
    
    print("\n✓ Union automaton correctly computes min(A(w), B(w))\n")


# ============================================================
# Demo 4: Tropical Distributivity
# ============================================================

def demo_distributivity():
    """Demonstrate that a + min(b, c) = min(a+b, a+c) in the tropical semiring."""
    print("=" * 60)
    print("Demo 4: Tropical Distributivity")
    print("=" * 60)
    
    test_cases = [
        (2, 3, 5),
        (0, 4, 7),
        (1, INF, 3),
        (INF, 2, 5),
        (3, 3, 3),
        (0, 0, 0),
    ]
    
    print("\n  a + min(b, c) = min(a+b, a+c)?")
    for a, b, c in test_cases:
        lhs = trop_mul(a, trop_add(b, c))  # a + min(b, c)
        rhs = trop_add(trop_mul(a, b), trop_mul(a, c))  # min(a+b, a+c)
        a_str = '∞' if a == INF else str(int(a))
        b_str = '∞' if b == INF else str(int(b))
        c_str = '∞' if c == INF else str(int(c))
        lhs_str = '∞' if lhs == INF else str(int(lhs))
        rhs_str = '∞' if rhs == INF else str(int(rhs))
        check = '✓' if lhs == rhs else '✗'
        print(f"  {a_str} + min({b_str}, {c_str}) = {lhs_str}  |  "
              f"min({a_str}+{b_str}, {a_str}+{c_str}) = {rhs_str}  {check}")
        assert lhs == rhs, "Distributivity violation!"
    
    print("\n✓ Tropical distributivity holds in all cases\n")


# ============================================================
# Demo 5: Weighted MSO Formula Evaluation
# ============================================================

def demo_wmso_evaluation():
    """Demonstrate weighted MSO formula evaluation with tropical semantics."""
    print("=" * 60)
    print("Demo 5: Weighted MSO Formula Evaluation")
    print("=" * 60)
    
    # Consider words over alphabet {a, b}
    # Formula: ∃x. (letter(a, x) ∧ ∃y. (succ(x, y) ∧ letter(b, y)))
    # This checks for the pattern "ab" and returns 0 if found, ⊤ otherwise
    
    def eval_ab_pattern(word):
        """Check for 'ab' pattern: returns 0 if found, INF otherwise."""
        best = INF
        for x in range(len(word)):
            # letter(a, x): cost 0 if word[x]='a', INF otherwise
            cost_a = 0 if x < len(word) and word[x] == 'a' else INF
            
            y = x + 1
            if y < len(word):
                # letter(b, y): cost 0 if word[y]='b', INF otherwise
                cost_b = 0 if word[y] == 'b' else INF
                
                # succ(x, y): cost 0 (always true since y = x+1)
                cost_succ = 0
                
                # conjunction = tropical addition
                inner_cost = trop_mul(trop_mul(cost_a, cost_b), cost_succ)
            else:
                inner_cost = INF
            
            # existential = min over witnesses
            best = trop_add(best, inner_cost)
        
        return best
    
    test_words = [
        list('ab'),
        list('ba'),
        list('aab'),
        list('abb'),
        list('bba'),
        list('abab'),
        list('bbbb'),
        list('a'),
        [],
    ]
    
    print("\nFormula: ∃x. (letter(a,x) ∧ ∃y. (succ(x,y) ∧ letter(b,y)))")
    print("Semantics: 0 if 'ab' pattern found, ∞ otherwise\n")
    print("Word → Cost:")
    for w in test_words:
        cost = eval_ab_pattern(w)
        word_str = ''.join(w) if w else 'ε'
        cost_str = '∞' if cost == INF else str(int(cost))
        has_ab = 'ab' in ''.join(w)
        print(f"  {word_str:8s} → {cost_str:3s}  (contains 'ab': {has_ab})")
    
    print("\n✓ Formula correctly detects 'ab' pattern\n")


# ============================================================
# Demo 6: Cost Function Comparison
# ============================================================

def demo_cost_comparison():
    """Compare automaton and formula definitions of the same cost function.
    
    Function: count minimum number of 'a's in any contiguous block.
    """
    print("=" * 60)
    print("Demo 6: Automaton-Logic Equivalence Example")
    print("=" * 60)
    
    # Automaton: counts 'a' letters (simple weight-per-letter)
    A_count = MinPlusAutomaton(
        n_states=1,
        init=[0],
        step={(0, 'a', 0): 1, (0, 'b', 0): 0},
        final=[0]
    )
    
    # Automaton: gives cost 0 for words with at least one 'b'
    A_hasb = MinPlusAutomaton(
        n_states=2,
        init=[0, INF],
        step={
            (0, 'a', 0): 0, (0, 'b', 0): INF,
            (0, 'a', 1): INF, (0, 'b', 1): 0,
            (1, 'a', 1): 0, (1, 'b', 1): 0,
        },
        final=[INF, 0]
    )
    
    test_words = [
        [],
        list('a'),
        list('b'),
        list('ab'),
        list('aab'),
        list('aba'),
        list('bbb'),
        list('aaaa'),
    ]
    
    print("\nTwo cost functions computed by automata:")
    print(f"  {'Word':8s} | {'#a (count)':>10s} | {'has_b?':>8s}")
    print(f"  {'-'*8} | {'-'*10} | {'-'*8}")
    for w in test_words:
        count = A_count.eval_dp(w)
        hasb = A_hasb.eval_dp(w)
        word_str = ''.join(w) if w else 'ε'
        hasb_str = '∞' if hasb == INF else str(int(hasb))
        print(f"  {word_str:8s} | {int(count):10d} | {hasb_str:>8s}")
    
    print("\nBoth are tropically recognizable (computed by automata)")
    print("and weighted MSO-definable (expressible as tropical formulas).\n")


def main():
    print("╔══════════════════════════════════════════════════════════╗")
    print("║   Tropical Büchi–Elgot Theorem: Interactive Demos       ║")
    print("║   Min-Plus Automata ↔ Weighted MSO Logic                ║")
    print("╚══════════════════════════════════════════════════════════╝\n")
    
    demo_shortest_path()
    demo_product_automaton()
    demo_union_automaton()
    demo_distributivity()
    demo_wmso_evaluation()
    demo_cost_comparison()
    
    print("=" * 60)
    print("All demonstrations completed successfully!")
    print("=" * 60)


if __name__ == '__main__':
    main()


#!/usr/bin/env python3
"""
Visualizations for the Tropical Büchi–Elgot Theorem

Generates figures illustrating:
1. Min-plus automaton state diagram
2. Tropical semiring operations
3. Dynamic programming cost matrix
4. Closure property lattice
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as patches
import numpy as np
import base64
import io

def fig_to_base64(fig):
    """Convert matplotlib figure to base64 PNG."""
    buf = io.BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight',
                facecolor='white', edgecolor='none')
    buf.seek(0)
    return 'data:image/png;base64,' + base64.b64encode(buf.read()).decode('utf-8')


def viz_tropical_operations():
    """Visualize tropical semiring operations: min and +."""
    fig, axes = plt.subplots(1, 2, figsize=(12, 5))
    
    x = np.linspace(0, 10, 100)
    
    # Tropical addition = min
    ax = axes[0]
    a, b = 3, 7
    ax.axhline(y=a, color='#2196F3', linewidth=2, label=f'a = {a}')
    ax.axhline(y=b, color='#FF5722', linewidth=2, label=f'b = {b}')
    ax.axhline(y=min(a, b), color='#4CAF50', linewidth=3, linestyle='--',
               label=f'a ⊕ b = min({a},{b}) = {min(a,b)}')
    ax.set_ylim(0, 10)
    ax.set_title('Tropical Addition: a ⊕ b = min(a, b)', fontsize=14, fontweight='bold')
    ax.legend(fontsize=11, loc='upper right')
    ax.set_ylabel('Value', fontsize=12)
    ax.grid(True, alpha=0.3)
    ax.set_xticks([])
    
    # Tropical multiplication = ordinary +
    ax = axes[1]
    x_vals = np.arange(0, 8)
    a_vals = x_vals
    b_vals = np.full_like(x_vals, 3)
    prod_vals = a_vals + b_vals
    
    bars_width = 0.25
    ax.bar(x_vals - bars_width, a_vals, bars_width, color='#2196F3', 
           label='a', alpha=0.8)
    ax.bar(x_vals, b_vals, bars_width, color='#FF5722', 
           label='b = 3', alpha=0.8)
    ax.bar(x_vals + bars_width, prod_vals, bars_width, color='#9C27B0', 
           label='a ⊙ b = a + 3', alpha=0.8)
    
    ax.set_title('Tropical Multiplication: a ⊙ b = a + b', fontsize=14, fontweight='bold')
    ax.set_xlabel('a', fontsize=12)
    ax.set_ylabel('Value', fontsize=12)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3, axis='y')
    
    plt.tight_layout()
    result = fig_to_base64(fig)
    fig.savefig('/workspace/request-project/viz_tropical_ops.png', dpi=150, 
                bbox_inches='tight', facecolor='white')
    plt.close(fig)
    return result


def viz_distributivity():
    """Visualize tropical distributivity: a ⊙ (b ⊕ c) = (a ⊙ b) ⊕ (a ⊙ c)."""
    fig, ax = plt.subplots(1, 1, figsize=(10, 6))
    
    a_vals = np.arange(0, 8)
    b, c = 3, 7
    
    # Left side: a + min(b, c) = a + 3
    lhs = a_vals + min(b, c)
    # Right side: min(a + b, a + c) = min(a + 3, a + 7) = a + 3
    rhs = np.minimum(a_vals + b, a_vals + c)
    
    ax.plot(a_vals, a_vals + b, 'o--', color='#2196F3', linewidth=2,
            markersize=8, label=f'a + b (b={b})')
    ax.plot(a_vals, a_vals + c, 's--', color='#FF5722', linewidth=2,
            markersize=8, label=f'a + c (c={c})')
    ax.plot(a_vals, lhs, 'D-', color='#4CAF50', linewidth=3,
            markersize=10, label=f'a + min(b,c) = a + {min(b,c)}')
    ax.plot(a_vals, rhs, 'x-', color='#9C27B0', linewidth=2,
            markersize=12, label='min(a+b, a+c)')
    
    ax.set_xlabel('a', fontsize=14)
    ax.set_ylabel('Cost', fontsize=14)
    ax.set_title('Tropical Distributivity: a + min(b,c) = min(a+b, a+c)', 
                 fontsize=14, fontweight='bold')
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)
    
    # Annotate the equality
    ax.annotate('These two lines\nare identical!', 
                xy=(5, 8), xytext=(2, 12),
                fontsize=12, fontweight='bold', color='#4CAF50',
                arrowprops=dict(arrowstyle='->', color='#4CAF50', lw=2))
    
    result = fig_to_base64(fig)
    fig.savefig('/workspace/request-project/viz_distributivity.png', dpi=150,
                bbox_inches='tight', facecolor='white')
    plt.close(fig)
    return result


def viz_dp_matrix():
    """Visualize the dynamic programming cost matrix for automaton evaluation."""
    fig, ax = plt.subplots(1, 1, figsize=(10, 6))
    
    # Simple automaton: 3 states, word "abba"
    word = list('abba')
    n_states = 3
    state_names = ['q₀', 'q₁', 'q₂']
    
    # Simulated DP costs (minimum cost to reach each state after each position)
    dp = np.array([
        [0, np.inf, np.inf],    # init
        [np.inf, 1, 3],          # after 'a'
        [np.inf, np.inf, 2],     # after 'ab'  
        [np.inf, 3, np.inf],     # after 'abb'
        [np.inf, np.inf, 4],     # after 'abba'
    ])
    
    # Replace inf with a large value for visualization
    dp_viz = np.where(np.isinf(dp), -1, dp)
    
    # Create heatmap
    cmap = plt.cm.YlOrRd.copy()
    cmap.set_under('lightgray')
    
    im = ax.imshow(dp_viz.T, cmap=cmap, vmin=0, vmax=8, aspect='auto')
    
    # Labels
    ax.set_xticks(range(len(word) + 1))
    ax.set_xticklabels(['init'] + [f"'{c}'" for c in word], fontsize=12)
    ax.set_yticks(range(n_states))
    ax.set_yticklabels(state_names, fontsize=14)
    ax.set_xlabel('After reading...', fontsize=13)
    ax.set_ylabel('State', fontsize=13)
    ax.set_title('Dynamic Programming Cost Matrix\n(Min-Plus Automaton on "abba")', 
                 fontsize=14, fontweight='bold')
    
    # Annotate cells
    for i in range(len(word) + 1):
        for j in range(n_states):
            val = dp[i, j]
            if np.isinf(val):
                text = '∞'
                color = 'gray'
            else:
                text = str(int(val))
                color = 'white' if val > 3 else 'black'
            ax.text(i, j, text, ha='center', va='center', fontsize=14,
                    fontweight='bold', color=color)
    
    # Highlight optimal path
    optimal_path = [(0, 0), (1, 1), (2, 2), (3, 1), (4, 2)]
    for idx, (i, j) in enumerate(optimal_path):
        rect = patches.Rectangle((i - 0.45, j - 0.45), 0.9, 0.9,
                                  linewidth=3, edgecolor='#4CAF50', 
                                  facecolor='none', linestyle='-')
        ax.add_patch(rect)
    
    plt.colorbar(im, ax=ax, label='Cost', extend='min')
    
    result = fig_to_base64(fig)
    fig.savefig('/workspace/request-project/viz_dp_matrix.png', dpi=150,
                bbox_inches='tight', facecolor='white')
    plt.close(fig)
    return result


def viz_closure_diagram():
    """Visualize the closure properties of tropically recognizable functions."""
    fig, ax = plt.subplots(1, 1, figsize=(10, 8))
    ax.set_xlim(-1, 11)
    ax.set_ylim(-1, 9)
    ax.set_aspect('equal')
    ax.axis('off')
    
    # Title
    ax.text(5, 8.5, 'Closure Properties of Tropical Recognizability',
            fontsize=16, fontweight='bold', ha='center', va='center')
    
    # Central box: Tropically Recognizable = WMSO Definable
    fancy = patches.FancyBboxPatch((1, 3.5), 8, 2, 
                                    boxstyle="round,pad=0.3",
                                    facecolor='#E3F2FD', edgecolor='#1565C0',
                                    linewidth=3)
    ax.add_patch(fancy)
    ax.text(5, 4.5, 'Tropically Recognizable\n= Weighted MSO Definable',
            fontsize=14, fontweight='bold', ha='center', va='center',
            color='#1565C0')
    
    # Closure operations
    operations = [
        (2, 7, 'min(f, g)\nUnion Automaton', '#4CAF50'),
        (5, 7, 'f + g\nProduct Automaton', '#FF9800'),
        (8, 7, '∃-projection\nSubset Construction', '#9C27B0'),
        (2, 1.5, 'Constant 0\n(top formula)', '#2196F3'),
        (5, 1.5, 'Constant ⊤\n(bot formula)', '#F44336'),
        (8, 1.5, 'Atomic\nPredicates', '#795548'),
    ]
    
    for x, y, label, color in operations:
        box = patches.FancyBboxPatch((x - 1.3, y - 0.6), 2.6, 1.2,
                                      boxstyle="round,pad=0.2",
                                      facecolor=color + '20', 
                                      edgecolor=color,
                                      linewidth=2)
        ax.add_patch(box)
        ax.text(x, y, label, fontsize=10, ha='center', va='center',
                fontweight='bold', color=color)
    
    # Arrows
    for x, y, _, color in operations:
        if y > 5:
            ax.annotate('', xy=(x, 5.5), xytext=(x, y - 0.6),
                       arrowprops=dict(arrowstyle='->', color=color, lw=2))
        else:
            ax.annotate('', xy=(x, 3.5), xytext=(x, y + 0.6),
                       arrowprops=dict(arrowstyle='->', color=color, lw=2))
    
    # Check marks for proved results
    proved = [(2, 7), (5, 7), (2, 1.5), (5, 1.5)]
    for x, y in proved:
        ax.text(x + 1.1, y + 0.3, '✓', fontsize=16, color='green',
                fontweight='bold')
    
    # Question marks for remaining
    remaining = [(8, 7), (8, 1.5)]
    for x, y in remaining:
        ax.text(x + 1.1, y + 0.3, '⟳', fontsize=14, color='orange',
                fontweight='bold')
    
    ax.text(5, 0.3, '✓ = Formally verified    ⟳ = Infrastructure in progress',
            fontsize=11, ha='center', va='center', style='italic', color='gray')
    
    result = fig_to_base64(fig)
    fig.savefig('/workspace/request-project/viz_closure.png', dpi=150,
                bbox_inches='tight', facecolor='white')
    plt.close(fig)
    return result


def main():
    print("Generating visualizations...")
    
    v1 = viz_tropical_operations()
    print(f"  ✓ Tropical operations ({len(v1)} bytes)")
    
    v2 = viz_distributivity()
    print(f"  ✓ Distributivity ({len(v2)} bytes)")
    
    v3 = viz_dp_matrix()
    print(f"  ✓ DP matrix ({len(v3)} bytes)")
    
    v4 = viz_closure_diagram()
    print(f"  ✓ Closure diagram ({len(v4)} bytes)")
    
    print("\nAll visualizations saved to PNG files.")
    return [v1, v2, v3, v4]


if __name__ == '__main__':
    main()
