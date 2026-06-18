# A Tropical Myhill–Nerode Theorem: Canonical Minimization and Syntactic Monoids for Min-Plus Weighted Automata

## Abstract

We develop a complete Myhill–Nerode theory for tropical (min-plus) weighted languages over the semiring (WithTop ℕ, min, +, ⊤, 0). Our contributions include: (1) a tropical Nerode equivalence defined via residual (derivative) functions, shown to be an equivalence relation and right congruence; (2) a constructive canonical Nerode automaton whose states are residual functions; (3) a recognition theorem: a weighted language is recognizable by a finite-state tropical automaton if and only if it has finitely many distinct residuals; (4) a minimality theorem: the Nerode automaton has the fewest states among all recognizing automata, with every recognizing automaton admitting a surjection from its reachable states onto the Nerode states; (5) a syntactic characterization: recognizability is equivalent to finiteness of the syntactic transformation monoid. All results are formalized and machine-verified in Lean 4 with Mathlib, providing the first complete, formally verified tropical Myhill–Nerode package.

**Keywords:** Tropical semiring, min-plus algebra, weighted automata, Myhill–Nerode theorem, syntactic monoid, formal verification, automata minimization

## 1. Introduction

### 1.1 Motivation

The Myhill–Nerode theorem is a cornerstone of automata theory, providing a canonical characterization of regular languages through the finiteness of a right congruence on words. For classical (Boolean) automata, the theorem yields: a language is regular iff it has finitely many Nerode equivalence classes; the canonical automaton with states being these classes is minimal; and regularity is equivalent to finiteness of the syntactic monoid.

Weighted automata generalize Boolean automata by assigning quantitative values to strings, with applications to shortest-path computation, speech recognition, natural language processing, and compiler optimization. Among weighted automata, *tropical* (min-plus) automata are particularly important: they operate over the semiring (ℝ∪{∞}, min, +, ∞, 0) and naturally model optimization problems where costs are accumulated additively and alternatives are compared by minimization.

Despite the fundamental importance of the Myhill–Nerode theorem and the ubiquity of tropical automata, a complete, rigorous tropical Myhill–Nerode package — including canonical automaton construction, minimality proofs, and syntactic monoid characterization — has not been available in formally verified form. We fill this gap.

### 1.2 Contributions

1. **Tropical Nerode equivalence** (Theorems 1–2): We define the Nerode relation via residual equality, prove it is an equivalence and right congruence.

2. **Nerode automaton** (Theorem 3): We construct the canonical automaton and prove correctness.

3. **Recognition characterization** (Theorem 4): We prove recognizability ↔ finite residual range.

4. **Minimality** (Theorem 5): We prove every recognizing automaton surjects onto the Nerode automaton and derive a state lower bound.

5. **Syntactic monoid** (Theorem 6): We prove recognizability ↔ finiteness of the syntactic transformation monoid.

6. **Formal verification**: All results are machine-verified in Lean 4/Mathlib with no axioms beyond propext, Classical.choice, and Quot.sound.

### 1.3 Related Work

The classical Myhill–Nerode theorem dates to Nerode (1958) and Myhill (1957). Extensions to weighted automata over general semirings have been studied by several authors:

- **Borchardt (2004)** developed a Myhill–Nerode theorem for weighted tree automata.
- **Droste & Gastin (2007)** established connections between weighted logics and recognizable series.
- **Kirsten & Lombardy (2009)** studied decidability questions for tropical automata.
- **Droste, Kuich & Vogler (2009)** provided a comprehensive treatment of weighted automata in their Handbook.

Our work differs in providing: (a) complete formal verification; (b) an explicit canonical automaton construction; (c) a syntactic monoid characterization specialized to the tropical case; (d) constructive proofs suitable for algorithmic extraction.

## 2. Definitions and Notation

### 2.1 The Tropical Semiring

We work over the tropical semiring **(WithTop ℕ, min, +, ⊤, 0)**, where:
- WithTop ℕ = ℕ ∪ {⊤} represents costs (natural numbers with infinity)
- Tropical addition: a ⊕ b = min(a, b)
- Tropical multiplication: a ⊗ b = a + b
- Additive identity (zero): ⊤ (infinity — neutral for min)
- Multiplicative identity (one): 0 (neutral for +)

### 2.2 Words and Languages

Let α be a type (alphabet). Words are elements of `List α`. A **tropical weighted language** is a function `L : List α → WithTop ℕ` assigning a cost to each word.

### 2.3 Residuals

**Definition 1** (Tropical Residual). The *right residual* of L at prefix u is:
```
Residual L u : List α → WithTop ℕ
Residual L u = fun v ↦ L (u ++ v)
```

**Definition 2** (Tropical Nerode Equivalence). Two words u, v are *Nerode equivalent* (u ~_L v) iff:
```
NerodeRel L u v ⟺ Residual L u = Residual L v
```
That is, u ~_L v iff ∀ w, L(uw) = L(vw).

### 2.4 Tropical DFA

**Definition 3** (Tropical DFA). A tropical deterministic finite automaton (TDFA) over alphabet α with state set σ is a tuple A = (step, init, output) where:
- step : σ → α → σ is the transition function
- init : σ is the initial state
- output : σ → WithTop ℕ is the output function

The evaluation function extends to words:
```
run A q [] = q
run A q (a :: w) = run A (step q a) w
eval A w = output (run A init w)
```

A TDFA *recognizes* L if ∀ w, eval A w = L w.

### 2.5 Recognizability

**Definition 4**. A weighted language L is *tropically recognizable* if there exists a TDFA with a finite state type that recognizes L.

## 3. Main Results

### 3.1 Theorem 1: Nerode Equivalence

**Theorem** (nerodeRel_equivalence). *For any weighted language L, the relation NerodeRel L is an equivalence relation.*

*Proof.* The relation is defined as equality of functions (Residual L u = Residual L v), hence it inherits reflexivity, symmetry, and transitivity from propositional equality. □

### 3.2 Theorem 2: Right Congruence

**Theorem** (nerodeRel_right_invariant). *If NerodeRel L u v, then NerodeRel L (u ++ w) (v ++ w) for any word w.*

*Proof.* We have Residual L (u ++ w) = Residual (Residual L u) w by the append lemma (associativity of concatenation). Similarly for v. Since Residual L u = Residual L v, the two composed residuals are equal. □

This makes NerodeRel L a *right congruence*: it is compatible with right concatenation of any word. This is the key structural property enabling the quotient automaton construction.

### 3.3 Theorem 3: Nerode Automaton

**Construction** (NerodeAut). Given L, define the Nerode automaton:
- **States**: Set.range (Residual L), the set of all residual functions
- **Initial state**: ⟨Residual L [], ...⟩ = ⟨L, ...⟩ (residual at empty prefix is L itself)
- **Transition**: nerodeStep L f a sends residual f (with representative prefix u) to Residual L (u ++ [a])
- **Output**: output f = f [] (evaluate the residual at the empty suffix)

**Theorem** (NerodeAut_recognizes). *The Nerode automaton recognizes L, i.e., for all w, eval (NerodeAut L) w = L w.*

*Proof sketch.* By induction on w, we show that running the Nerode automaton from the initial state on word w reaches the state whose value is Residual L w. The key lemma (NerodeAut_run_val) establishes:
```
(run (NerodeAut L) ⟨Residual L u, _⟩ w).val = Residual L (u ++ w)
```
Starting from u = [] and evaluating the output at [], we get L w. □

### 3.4 Theorem 4: Recognition Characterization

**Theorem** (trop_recognizable_iff_finite_range). *A weighted language L is tropically recognizable if and only if Set.range (Residual L) is finite.*

*Proof.*
- **(⇒)** If A with Fintype σ recognizes L, then Residual L u = A.residualAt (run A init u) for all u. Thus Set.range (Residual L) ⊆ Set.range A.residualAt. Since σ is finite, Set.range A.residualAt is finite, and so is any subset.

- **(⇐)** If Set.range (Residual L) is finite, equip it with a Fintype instance and use the Nerode automaton as the witness. □

### 3.5 Theorem 5: Minimality

**Theorem** (nerode_minimal). *For any TDFA A recognizing L, there exists a surjection from the reachable states of A onto Set.range (Residual L).*

*Proof.* Define f(q) = ⟨A.residualAt q, ...⟩. For surjectivity: given any residual Residual L w in the range, the state run A init w is reachable and maps to it (since Residual L w = A.residualAt (run A init w)). □

**Corollary** (nerode_state_lower_bound). *If A recognizes L and has finitely many reachable states, then:*
```
|Set.range (Residual L)| ≤ |Reachable A|
```

This is the tropical analogue of the classical DFA minimality theorem.

### 3.6 Theorem 6: Syntactic Monoid Characterization

**Definition 5** (Residual Action). Each word w induces a transformation on residual states:
```
residualAction L w : Set.range (Residual L) → Set.range (Residual L)
residualAction L w f = ⟨Residual L (u ++ w), ...⟩   (where u is a representative of f)
```

**Definition 6** (Syntactic Monoid). The *tropical syntactic monoid* is:
```
SyntacticMonoid L = Set.range (residualAction L)
```
i.e., the set of all transformations on residual states induced by words.

**Theorem** (trop_recognizable_iff_finite_syntactic). *L is tropically recognizable iff SyntacticMonoid L is finite.*

*Proof.*
- **(⇒)** If Set.range (Residual L) is finite (by Theorem 4), then the function space from it to itself is finite, and any subset — including SyntacticMonoid L — is finite.

- **(⇐)** If SyntacticMonoid L is finite, consider the orbit of the initial residual ⟨L, [],...⟩ under all word actions. Every residual Residual L w equals (residualAction L w ⟨L,...⟩).val, so Set.range (Residual L) is contained in the image of SyntacticMonoid L at the initial state, which is finite. □

## 4. Algorithms

### 4.1 Nerode Automaton Construction

**Algorithm 1: NerodeConstruct(L, α, k, p)**

Input: Language L, alphabet α, exploration depth k, probe depth p
Output: Minimal Nerode automaton

```
1. probes ← all words over α of length ≤ p
2. states ← ∅; transitions ← ∅; fp_map ← ∅
3. for each word w over α of length ≤ k:
4.     fp ← (L(w ++ s) for s in probes)    // fingerprint
5.     if fp ∉ fp_map:
6.         id ← |states|; states ← states ∪ {id}
7.         fp_map[fp] ← id; rep[id] ← w
8.     word_state[w] ← fp_map[fp]
9. for each state id, symbol a ∈ α:
10.    w' ← rep[id] ++ [a]
11.    fp' ← fingerprint(w')
12.    transitions[(id, a)] ← fp_map[fp']
13. init ← word_state[ε]
14. output[id] ← L(rep[id]) for each id
15. return (states, α, transitions, init, output)
```

**Complexity:** O(|α|^(k+p)) evaluations of L. For fixed alphabet and recognizable languages, the algorithm terminates when k exceeds the longest distinguishing prefix, which is bounded by the Nerode index.

### 4.2 Minimality Verification

**Algorithm 2: VerifyMinimality(A, NerodeAut)**

```
1. Compute reachable states of A by BFS
2. For each reachable state q, compute its residual fingerprint
3. Map each reachable state to its Nerode class
4. Verify surjectivity: every Nerode class has a preimage
5. Return |Nerode classes| ≤ |reachable states|
```

### 4.3 Syntactic Monoid Computation

**Algorithm 3: SyntacticMonoid(NerodeAut, k)**

```
1. transformations ← ∅
2. for each word w over α of length ≤ k:
3.     τ_w ← (residualAction(w, state) for state in states)
4.     transformations ← transformations ∪ {τ_w}
5. return transformations
```

**Complexity:** O(|α|^k · |states|) transition computations. For recognizable languages, the monoid stabilizes when k reaches the diameter of the Nerode automaton.

## 5. Computational Experiments

### 5.1 Bounded-Length Languages

For L(w) = min(|w|, n) over alphabet {a, b}:

| n | Nerode states | Syntactic monoid size | Expected states |
|---|---|---|---|
| 1 | 2 | 2 | 2 |
| 2 | 3 | 3 | 3 |
| 3 | 4 | 4 | 4 |
| 4 | 5 | 5 | 5 |
| 5 | 6 | 6 | 6 |

The pattern |states| = n + 1 is exact: the residuals are {min(k + |·|, n) : 0 ≤ k ≤ n}.

### 5.2 Minimality Demonstration

A non-minimal 4-state TDFA for L(w) = min(|w|, 2) was constructed with a redundant state. The Nerode construction produces the optimal 3-state automaton, confirming the state lower bound theorem.

### 5.3 Non-Recognizable Languages

For L(w) = |w|², every prefix of different length produces a distinct residual (since (n + k)² ≠ (m + k)² for some k when n ≠ m). The residual count grows without bound, confirming non-recognizability.

### 5.4 Application: Network Routing

A routing cost function over {fiber, wireless, satellite} with costs {1, 3, 5} capped at 10 was analyzed. The Nerode construction yields 11 minimal states, compressing the infinite space of path histories.

## 6. Discussion

### 6.1 Comparison with Classical Theory

The tropical Myhill–Nerode theorem closely parallels the classical version:

| Classical | Tropical |
|---|---|
| L : List α → Bool | L : List α → WithTop ℕ |
| Nerode: u ~v iff ∀w, uw∈L ↔ vw∈L | Nerode: u ~v iff ∀w, L(uw) = L(vw) |
| Equivalence classes | Residual functions |
| Regular ↔ finite index | Recognizable ↔ finite residuals |
| Minimal DFA | Minimal TDFA (Nerode automaton) |
| Syntactic monoid | Syntactic transformation monoid |

The key difference is that tropical equivalence classes are identified by *functions* (residuals) rather than by binary membership, making the structure richer and the proofs more delicate.

### 6.2 On Idempotence

The tropical semiring is idempotent (min(a, a) = a), but this does not imply that the syntactic transformation monoid consists of idempotent elements. A simple counterexample: for L(w) = min(|w|, 3), the transformation τ_a (append 'a') maps state k to state min(k+1, 3). This is not idempotent since τ_a ∘ τ_a maps k to min(k+2, 3) ≠ min(k+1, 3) in general. However, the monoid is always finite for recognizable languages, and eventual idempotence (τ^n = τ^(n+1) for large n) holds in finite transformation monoids by the pigeonhole principle.

### 6.3 Limitations

Our formalization uses `WithTop ℕ` rather than a general tropical semiring. This is deliberate: `WithTop ℕ` has excellent Lean/Mathlib support, and the essential ideas transfer to other ordered semirings. Generalization to arbitrary semirings would require additional algebraic infrastructure but no new proof ideas.

## 7. Future Work

1. **Tropical L* algorithm**: Adapt Angluin's learning algorithm to learn minimal tropical automata from cost queries.

2. **Tropical Kleene theorem**: Characterize recognizable tropical languages as closures of rational tropical expressions.

3. **Weighted MSO logic**: Connect tropical recognizability to a weighted monadic second-order logic.

4. **Categorical framework**: Develop the universal property of the Nerode automaton in categorical terms, generalizing to arbitrary semirings.

5. **Decidability**: Formalize decidability of equivalence for tropical automata using the Nerode characterization.

## 8. References

1. Nerode, A. (1958). "Linear automaton transformations." *Proceedings of the AMS*, 9(4), 541–544.

2. Myhill, J. (1957). "Finite automata and the representation of events." *WADD TR-57-624*.

3. Droste, M., Kuich, W., & Vogler, H. (2009). *Handbook of Weighted Automata*. Springer.

4. Simon, I. (1988). "Recognizable sets with multiplicities in the tropical semiring." *MFCS 1988*, LNCS 324, 107–120.

5. Borchardt, B. (2004). "The Myhill–Nerode theorem for recognizable tree series." *DLT 2003*, LNCS 2710, 146–158.

6. Droste, M. & Gastin, P. (2007). "Weighted automata and weighted logics." *TCS*, 380(1–2), 69–86.

7. Kirsten, D. & Lombardy, S. (2009). "Deciding unambiguity and sequentiality of polynomially ambiguous min-plus automata." *STACS 2009*, LNCS 5404, 589–600.

8. Pin, J.E. (1986). *Varieties of Formal Languages*. Plenum Press.

9. Angluin, D. (1987). "Learning regular sets from queries and counterexamples." *Information and Computation*, 75(2), 87–106.

10. The Mathlib Community (2020–). *Mathlib: A unified library of mathematics formalized in Lean*. https://github.com/leanprover-community/mathlib4
