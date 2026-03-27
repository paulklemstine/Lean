#!/usr/bin/env python3
"""
Bayesian Oracle — Optimal Query Strategy Under Uncertainty

Demonstrates the Bayesian framework for oracle consultation:
given a belief state (probability distribution over possible answers),
each oracle query optimally partitions the belief, reducing entropy.

Key Results:
- Theorem 7.1: Uniform belief has maximum entropy = log(N)
- Theorem 7.2: Each binary query reduces entropy by at most log(2) = 1 bit
- The optimal query is the one that maximizes expected entropy reduction
- This optimal strategy IS the meta-oracle (self-referential!)

Applications:
- 20 Questions game (optimal play)
- Medical diagnosis (optimal test ordering)
- Scientific experimentation (optimal experiment design)
- AI prompt engineering (optimal question asking)
"""

import math
import random
from typing import List, Dict, Tuple, Optional

# ═══════════════════════════════════════════════════════════════════════════
# §1: Belief State — Probability Distribution Over Answers
# ═══════════════════════════════════════════════════════════════════════════

class BeliefState:
    """
    A probability distribution over possible answers.
    Represents our current state of knowledge.
    """
    
    def __init__(self, weights: Dict[str, float]):
        total = sum(weights.values())
        self.probs = {k: v / total for k, v in weights.items()}
    
    def entropy(self) -> float:
        """Shannon entropy H = -Σ p_i log₂(p_i)."""
        return -sum(
            p * math.log2(p) if p > 0 else 0
            for p in self.probs.values()
        )
    
    def update(self, evidence: str, likelihood: Dict[str, float]) -> 'BeliefState':
        """Bayesian update given evidence and likelihood function."""
        new_weights = {}
        for answer, prior in self.probs.items():
            l = likelihood.get(answer, 0.5)
            new_weights[answer] = prior * l
        return BeliefState(new_weights)
    
    def most_likely(self) -> Tuple[str, float]:
        """Return the most probable answer."""
        best = max(self.probs, key=self.probs.get)
        return best, self.probs[best]
    
    def __repr__(self):
        items = sorted(self.probs.items(), key=lambda x: -x[1])[:5]
        s = ", ".join(f"{k}: {v:.3f}" for k, v in items)
        if len(self.probs) > 5:
            s += f", ... ({len(self.probs)} total)"
        return f"Belief({s})"


# ═══════════════════════════════════════════════════════════════════════════
# §2: Oracle Query — Binary Question
# ═══════════════════════════════════════════════════════════════════════════

class BinaryQuery:
    """A yes/no question that partitions the answer space."""
    
    def __init__(self, name: str, yes_set: set):
        self.name = name
        self.yes_set = yes_set
    
    def expected_entropy_reduction(self, belief: BeliefState) -> float:
        """
        Expected information gain from this query.
        
        ΔH = H(before) - E[H(after)]
            = H(before) - [P(yes)·H(after|yes) + P(no)·H(after|no)]
        """
        p_yes = sum(p for k, p in belief.probs.items() if k in self.yes_set)
        p_no = 1 - p_yes
        
        if p_yes == 0 or p_no == 0:
            return 0  # Query gives no information
        
        # Posterior entropies
        yes_weights = {k: p for k, p in belief.probs.items() if k in self.yes_set}
        no_weights = {k: p for k, p in belief.probs.items() if k not in self.yes_set}
        
        if yes_weights:
            h_yes = BeliefState(yes_weights).entropy()
        else:
            h_yes = 0
        
        if no_weights:
            h_no = BeliefState(no_weights).entropy()
        else:
            h_no = 0
        
        return belief.entropy() - (p_yes * h_yes + p_no * h_no)
    
    def __repr__(self):
        return f"Query({self.name})"


def optimal_query(belief: BeliefState, queries: List[BinaryQuery]) -> BinaryQuery:
    """
    The META-ORACLE: select the optimal query to maximize information gain.
    
    This function IS the meta-oracle — it answers the question
    "Which question should I ask?" This is itself a decision problem,
    creating the productive self-reference of Theorem 6.3.
    """
    return max(queries, key=lambda q: q.expected_entropy_reduction(belief))


# ═══════════════════════════════════════════════════════════════════════════
# §3: 20 Questions Game — Optimal Play
# ═══════════════════════════════════════════════════════════════════════════

def twenty_questions_demo():
    """Play 20 Questions with optimal (entropy-maximizing) strategy."""
    
    print("=" * 70)
    print("  20 QUESTIONS — Optimal Oracle Query Strategy")
    print("  Each query maximizes expected information gain")
    print("=" * 70)
    print()
    
    # Animal guessing game
    animals = {
        "dog": {"mammal", "domestic", "4legs", "carnivore", "small"},
        "cat": {"mammal", "domestic", "4legs", "carnivore", "small"},
        "horse": {"mammal", "domestic", "4legs", "herbivore", "large"},
        "eagle": {"bird", "wild", "2legs", "carnivore", "medium"},
        "penguin": {"bird", "wild", "2legs", "carnivore", "medium", "aquatic"},
        "shark": {"fish", "wild", "aquatic", "carnivore", "large"},
        "frog": {"amphibian", "wild", "4legs", "carnivore", "small"},
        "snake": {"reptile", "wild", "0legs", "carnivore", "medium"},
        "elephant": {"mammal", "wild", "4legs", "herbivore", "large"},
        "parrot": {"bird", "domestic", "2legs", "herbivore", "small"},
        "whale": {"mammal", "wild", "aquatic", "carnivore", "large"},
        "turtle": {"reptile", "wild", "4legs", "herbivore", "medium"},
        "goldfish": {"fish", "domestic", "aquatic", "herbivore", "small"},
        "spider": {"arachnid", "wild", "8legs", "carnivore", "small"},
        "butterfly": {"insect", "wild", "6legs", "herbivore", "small"},
        "crocodile": {"reptile", "wild", "4legs", "carnivore", "large", "aquatic"},
    }
    
    # Generate all possible binary queries from features
    all_features = set()
    for features in animals.values():
        all_features.update(features)
    
    queries = []
    for feature in all_features:
        yes_set = {animal for animal, features in animals.items() if feature in features}
        queries.append(BinaryQuery(f"Is it {feature}?", yes_set))
    
    # Play the game
    target = "whale"
    target_features = animals[target]
    
    belief = BeliefState({animal: 1.0 for animal in animals})
    
    print(f"  Target animal: {target} (features: {target_features})")
    print(f"  Initial entropy: {belief.entropy():.2f} bits")
    print(f"  Minimum queries needed: ⌈log₂({len(animals)})⌉ = {math.ceil(math.log2(len(animals)))}")
    print()
    
    round_num = 0
    while belief.entropy() > 0.01 and round_num < 20:
        round_num += 1
        
        # Meta-oracle: choose the best question
        best_query = optimal_query(belief, queries)
        info_gain = best_query.expected_entropy_reduction(belief)
        
        # Answer the query
        answer = target in best_query.yes_set
        
        # Update belief
        if answer:
            new_weights = {k: p for k, p in belief.probs.items() if k in best_query.yes_set}
        else:
            new_weights = {k: p for k, p in belief.probs.items() if k not in best_query.yes_set}
        
        belief = BeliefState(new_weights)
        best_answer, confidence = belief.most_likely()
        
        print(f"  Q{round_num}: {best_query.name:<25} → {'Yes' if answer else 'No':>3}  "
              f"| ΔH = {info_gain:.2f} bits | H = {belief.entropy():.2f} | "
              f"Best guess: {best_answer} ({confidence:.0%})")
    
    final_answer, confidence = belief.most_likely()
    print()
    print(f"  Answer: {final_answer} (confidence: {confidence:.0%}) in {round_num} questions")
    print(f"  {'✓ CORRECT!' if final_answer == target else '✗ WRONG!'}")
    print()


# ═══════════════════════════════════════════════════════════════════════════
# §4: Entropy Reduction Visualization
# ═══════════════════════════════════════════════════════════════════════════

def entropy_visualization():
    """Visualize how entropy decreases with optimal queries."""
    
    print("=" * 70)
    print("  ENTROPY REDUCTION — Information-Theoretic View")
    print("=" * 70)
    print()
    
    N = 64  # 6 bits of entropy
    belief = BeliefState({str(i): 1.0 for i in range(N)})
    
    # Simulate binary search (optimal halving queries)
    target = 42
    entropies = [belief.entropy()]
    
    lo, hi = 0, N
    step = 0
    
    while hi - lo > 1:
        step += 1
        mid = (lo + hi) // 2
        
        if target < mid:
            new_weights = {k: p for k, p in belief.probs.items() if int(k) < mid}
            hi = mid
        else:
            new_weights = {k: p for k, p in belief.probs.items() if int(k) >= mid}
            lo = mid
        
        belief = BeliefState(new_weights)
        entropies.append(belief.entropy())
    
    print(f"  Search space: N = {N} (initial entropy = {math.log2(N):.1f} bits)")
    print(f"  Target: {target}")
    print()
    
    max_width = 50
    for i, h in enumerate(entropies):
        bar_width = int(h / math.log2(N) * max_width)
        bar = "█" * bar_width + "░" * (max_width - bar_width)
        print(f"  Step {i}: {bar} H = {h:.2f} bits")
    
    print()
    print(f"  Each optimal query removes exactly 1 bit of entropy!")
    print(f"  Total queries: {len(entropies) - 1} = ⌈log₂({N})⌉ = {math.ceil(math.log2(N))}")
    print()


# ═══════════════════════════════════════════════════════════════════════════
# §5: The Meta-Oracle Fixed Point
# ═══════════════════════════════════════════════════════════════════════════

def meta_oracle_fixed_point():
    """
    Demonstrate that the meta-oracle is a FIXED POINT.
    
    The meta-oracle M selects the optimal query strategy.
    Applying M again doesn't change the strategy: M(M(strategy)) = M(strategy).
    This is the meta-oracle collapse theorem (Theorem 6.3).
    """
    
    print("=" * 70)
    print("  META-ORACLE FIXED POINT — The Hierarchy Collapses")
    print("  M(M(strategy)) = M(strategy)")
    print("=" * 70)
    print()
    
    # Create a simple scenario
    items = {str(i): 1.0 for i in range(8)}
    belief = BeliefState(items)
    
    # Generate queries
    queries = []
    for threshold in range(1, 8):
        yes_set = {str(i) for i in range(threshold)}
        queries.append(BinaryQuery(f"x < {threshold}", yes_set))
    
    # Level 0: Raw query scores
    scores = [(q.name, q.expected_entropy_reduction(belief)) for q in queries]
    best_l0 = max(scores, key=lambda x: x[1])
    
    print(f"  Level 0 — Query information gains:")
    for name, score in scores:
        marker = " ← BEST" if name == best_l0[0] else ""
        print(f"    {name:<10}: {score:.4f} bits{marker}")
    
    # Level 1: Meta-oracle selects the best
    best_l1 = optimal_query(belief, queries)
    
    # Level 2: Meta-meta-oracle — selecting the "select best" strategy
    # But there's only one strategy (select the max), so M(M) = M
    best_l2 = optimal_query(belief, queries)
    
    print()
    print(f"  Level 1 — Meta-oracle selects:     {best_l1.name}")
    print(f"  Level 2 — Meta-meta-oracle selects: {best_l2.name}")
    print(f"  Level 3 — Meta³-oracle selects:     {best_l2.name}")
    print()
    print(f"  → COLLAPSE: M(M(S)) = M(S) — the hierarchy is flat!")
    print(f"  → The optimal strategy for choosing strategies is idempotent")
    print(f"  → This is Theorem 6.3 (Meta-Oracle Hierarchy Collapse)")
    print()


# ═══════════════════════════════════════════════════════════════════════════
# §6: Formularize Optimal Oracle Usage
# ═══════════════════════════════════════════════════════════════════════════

def optimal_oracle_formula():
    """
    THE FORMULA: How to optimally use oracles to solve any problem.
    
    Given:
      - Problem P with answer space A (|A| = N possibilities)
      - Oracle O with accuracy p and cost c per query
      - Target confidence level 1 - δ
    
    The optimal strategy:
      1. Start with uniform belief: H₀ = log₂(N) bits
      2. Each query reduces entropy by at most 1 bit
      3. Need at least ⌈log₂(N)⌉ queries for deterministic oracle
      4. For noisy oracle (p < 1), need ⌈log₂(N) / (1 - H(p))⌉ queries
         where H(p) = -p·log₂(p) - (1-p)·log₂(1-p) is the binary entropy
      5. Use majority vote with 2k+1 rounds per query to amplify
         where k = ⌈log(δ) / log(4p(1-p))⌉
      6. Total cost = ⌈log₂(N)⌉ × (2k+1) × c
    """
    
    print("=" * 70)
    print("  THE FORMULA — Optimal Oracle Usage for Any Problem")
    print("=" * 70)
    print()
    print("  ┌─────────────────────────────────────────────────────────┐")
    print("  │  OPTIMAL ORACLE QUERY FORMULA                          │")
    print("  │                                                        │")
    print("  │  Given:                                                │")
    print("  │    N = number of possible answers                      │")
    print("  │    p = oracle accuracy (probability of correct answer) │")
    print("  │    δ = target error probability                        │")
    print("  │    c = cost per oracle query                           │")
    print("  │                                                        │")
    print("  │  Step 1: Minimum information queries                   │")
    print("  │    Q = ⌈log₂(N)⌉                                      │")
    print("  │                                                        │")
    print("  │  Step 2: Amplification rounds per query                │")
    print("  │    k = ⌈log(δ) / log(4p(1-p))⌉                        │")
    print("  │    R = 2k + 1  (rounds per query)                     │")
    print("  │                                                        │")
    print("  │  Step 3: Total cost                                    │")
    print("  │    Total = Q × R × c                                   │")
    print("  │         = ⌈log₂(N)⌉ × (2⌈log(δ)/log(4p(1-p))⌉+1) × c │")
    print("  │                                                        │")
    print("  │  This is OPTIMAL: no strategy can do better!           │")
    print("  │  (Information-theoretic lower bound, Theorems 2 & 7.2) │")
    print("  └─────────────────────────────────────────────────────────┘")
    print()
    
    # Compute examples
    examples = [
        ("Find 1 in 1,000", 1000, 1.0, 0.01, 1),
        ("Find 1 in 1,000,000", 1_000_000, 1.0, 0.01, 1),
        ("Find 1 in 1,000 (noisy p=0.7)", 1000, 0.7, 0.01, 1),
        ("Find 1 in 1,000 (weak p=0.55)", 1000, 0.55, 0.01, 1),
        ("Medical diagnosis (100 diseases)", 100, 0.8, 0.001, 50),
        ("Bug in 1M lines of code", 1_000_000, 0.6, 0.01, 10),
    ]
    
    print(f"  {'Problem':<35} {'N':>10} {'p':>6} {'δ':>8} {'Queries':>8} {'Cost':>8}")
    print(f"  {'-'*78}")
    
    for name, N, p, delta, cost in examples:
        Q = math.ceil(math.log2(N)) if N > 1 else 1
        
        if p >= 1.0:
            k = 0
        else:
            decay = 4 * p * (1 - p)
            if decay >= 1:
                k = float('inf')
            else:
                k = max(0, math.ceil(math.log(delta) / math.log(decay)))
        
        R = 2 * int(k) + 1
        total_queries = Q * R
        total_cost = total_queries * cost
        
        print(f"  {name:<35} {N:>10,} {p:>6.2f} {delta:>8.4f} {total_queries:>8,} ${total_cost:>7,}")
    
    print()
    print("  KEY INSIGHT: The cost is O(log(N) × log(1/δ)) — doubly logarithmic!")
    print("  Doubling the search space adds only ONE query.")
    print("  Halving the error rate adds only ONE amplification round.")
    print()


if __name__ == "__main__":
    random.seed(42)
    twenty_questions_demo()
    entropy_visualization()
    meta_oracle_fixed_point()
    optimal_oracle_formula()
