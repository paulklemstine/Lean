# Future Directions: Tropical Metamathematics

This document outlines five specific, theorem-driven research directions opened by the tropical metamathematics program. Each direction includes precise conjectures, proof strategies, and cross-domain connections.

---

## 1. Tropical Löb Theorem

**Goal:** Formalize a tropical provability modality induced by closure/fixed-point semantics and prove a Löb-style theorem.

**Background:** In classical modal logic, Löb's theorem states: if a proof system proves "if □P then P," then it already proves P. The classical proof uses the diagonal lemma to construct a sentence L asserting "if □L then L," then exploits the Hilbert-Bernays derivability conditions.

**Tropical Formulation:**

Define a tropical provability modality □ as a closure operator `c` on `Fin n → WithTop ℝ` satisfying:
- Extensivity: `x ≤ c x` (soundness — provable bounds are at least as strong as actual)
- Monotonicity: `x ≤ y → c x ≤ c y`
- Idempotency: `c (c x) = c x`

**Conjecture (Tropical Löb):**
```
theorem tropical_loeb
  {n : ℕ} [NeZero n]
  (c : (Fin n → WithTop ℝ) → (Fin n → WithTop ℝ))
  (hmono : Monotone c) (hext : ∀ x, x ≤ c x) (hidem : ∀ x, c (c x) = c x)
  (Prov : (Fin n → WithTop ℝ) → Fin n → Prop)
  (i : Fin n)
  (hloeb_hyp : ∀ x, c x = x → (Prov x i → TropProvable x i) → TropProvable x i) :
  ∀ x, c x = x → TropProvable x i
```

**Proof Strategy:** Use the fixed-point existence theorem from our formalization to construct the Löb sentence. The key step is showing that closure idempotency provides the necessary "internal provability" reflection principle.

**Cross-Domain Connection:** Löb's theorem governs self-referential agents in game theory and AI alignment (Löbian cooperation). A tropical Löb theorem would give cost-aware versions of these results, where agents reason about proof *costs* rather than mere provability.

---

## 2. Bellman–Gödel Barrier for Verification

**Goal:** Show that tropical fixed points arising from shortest-path/Bellman operators admit self-referential specifications that cannot be both internally certified and complete.

**Background:** The Bellman operator `T` in dynamic programming is defined by `T(v)(s) = min_a [c(s,a) + γ · v(s')]`. It is a contraction mapping on value functions, and its unique fixed point is the optimal value function. Crucially, `T` is monotone and, in the undiscounted case with finite state spaces, idempotent on the set of solutions.

**Conjecture (Bellman–Gödel Barrier):**
```
theorem bellman_godel_barrier
  {S A : Type*} [Fintype S] [Fintype A]
  (T : (S → WithTop ℝ) → (S → WithTop ℝ))
  (hmono : Monotone T) (hidem : ∀ v, T (T v) = T v)
  (Certifiable : (S → WithTop ℝ) → S → Prop)
  (hdiag : ∃ s, ∀ v, T v = v → (Certifiable v s ↔ ¬ Certifiable v s)) :
  -- No fixed point is fully certifiable
  ¬ ∃ v, T v = v ∧ ∀ s, Certifiable v s
```

**Proof Strategy:** This is a direct instantiation of our `lattice_fixed_point_incompleteness` theorem with `S = S → WithTop ℝ` and the Bellman operator playing the role of the closure. The diagonal hypothesis encodes a specification that refers to its own certifiability.

**Application:** This result would show that formal verification systems for optimal control (e.g., certified reinforcement learning) face fundamental limitations when the specification language is rich enough to encode self-reference.

---

## 3. MDL Lower Bounds for Self-Referential Tropical Sentences

**Goal:** Extend the closure-Kolmogorov duality to prove that diagonal tropical sentences have irreducible description length under any closure-complete coding.

**Background:** The existing `closure_mdl_bound_via_fixed_point` theorem shows that closure operators provide canonical representatives with bounded code length. The question is: do self-referential fixed points (tropical Gödel sentences) have *provably higher* description complexity than non-self-referential ones?

**Conjecture (Diagonal MDL Lower Bound):**
```
theorem diagonal_mdl_lower_bound
  {n : ℕ} [NeZero n]
  (c : (Fin n → WithTop ℝ) → (Fin n → WithTop ℝ))
  (hmono : Monotone c) (hext : ∀ x, x ≤ c x) (hidem : ∀ x, c (c x) = c x)
  (complexity : (Fin n → WithTop ℝ) → ℕ)
  (hcompress : ∀ x, complexity (c x) ≤ complexity x)
  (hfaithful : ∀ x y, c x = c y → complexity x = complexity y → x = y) :
  -- Any self-referential fixed point has complexity ≥ n
  ∀ x, c x = x → (∃ i, x i ≠ c x i → False) → complexity x ≥ n
```

**Proof Strategy:** The key insight is that a self-referential sentence must encode information about its own coordinate position within the state space, requiring at least `log n` bits. Combined with the closure-fixedness constraint, this yields a linear lower bound.

**Cross-Domain Connection:** This connects incompleteness to algorithmic information theory. A Gödel sentence is, in a sense, a shortest sentence escaping a proof system's closure — incompleteness as a lower bound on compressibility.

---

## 4. Categorical Tropical Recursion

**Goal:** Recast the tropical fixed-point/diagonalization construction using traced monoidal categories or Lawvere fixed-point semantics in an idempotent-enriched category.

**Background:** Lawvere's fixed-point theorem states: if there is a surjection `A × A → A` in a cartesian closed category, then every endomorphism of any object has a fixed point. Our tropical construction can be viewed as an instance of this in a category enriched over `(WithTop ℝ, min, +)`.

**Conjecture (Lawvere-Tropical Fixed Point):**
```
theorem lawvere_tropical_fixed_point
  {C : Type*} [Category C]
  (A B : C) (eval : A ⟶ B) (diag : A ⟶ A ⊗ A)
  (repr : A ⊗ A ⟶ A)
  (hsurj : ∀ f : A ⟶ B, ∃ a, eval ≫ ... = f) :
  ∀ f : B ⟶ B, ∃ b, f b = b
```

**Proof Strategy:** Formalize the construction in Mathlib's category theory library, using `Quiver`, `CategoryStruct`, and monoidal category infrastructure. The tropical enrichment would be modeled by `WithTop ℝ`-valued hom-sets.

**Cross-Domain Connection:** This would unify tropical metamathematics with categorical logic, potentially connecting to topos-theoretic interpretations of incompleteness and to the semantics of linear logic via the tropical/linear duality.

---

## 5. Undecidability Thresholds in Min-Plus Proof Search

**Goal:** Move from finite-state incompleteness schemas to explicit undecidability results for richer min-plus arithmetic fragments.

**Background:** Our current results show that finite tropical proof systems with diagonal expressivity are incomplete. The natural question is: at what point does tropical arithmetic become undecidable? The theory of min-plus (tropical) arithmetic is known to be decidable for certain fragments (e.g., tropical polynomial identity testing), but the boundary is not well understood.

**Conjecture (Tropical Arithmetic Undecidability Threshold):**
```
-- There exists a fragment of tropical arithmetic that is undecidable
theorem tropical_arithmetic_undecidability
  -- Sentences are tropical polynomial equations and inequalities
  (TropSentence : Type)
  (TropSemantics : TropSentence → Prop)
  -- The fragment includes diagonal self-reference
  (hexpressive : ∃ encode : (TropSentence → Prop) → TropSentence,
    ∀ P, TropSemantics (encode P) ↔ P (encode P)) :
  -- Then the validity problem is undecidable
  ¬ ∃ decide : TropSentence → Bool,
    ∀ s, (decide s = true ↔ TropSemantics s)
```

**Proof Strategy:** Encode a universal Turing machine computation as a tropical optimization problem (this is known to be possible via the connection between shortest paths and computation). Then use the diagonal fixed-point theorem to show that the halting problem reduces to tropical validity.

**Concrete Steps:**
1. Formalize tropical polynomial evaluation in Lean.
2. Show that min-plus matrix iteration can simulate Turing machine steps.
3. Construct the diagonal encoding using tropical quines.
4. Derive undecidability from the halting problem reduction.

**Cross-Domain Connection:** This would establish that tropical geometry has its own natural boundary between decidability and undecidability, paralleling the classical boundary at Peano arithmetic but occurring in a completely different algebraic setting.

---

## Research Program Summary

These five directions form a coherent research program in **tropical metamathematics**:

| Direction | Core Technique | Connects To |
|-----------|---------------|-------------|
| Tropical Löb | Closure modality + fixed point | AI alignment, game theory |
| Bellman–Gödel | DP operators + self-reference | Reinforcement learning, verification |
| Diagonal MDL | Compression + fixed points | Information theory, Kolmogorov complexity |
| Categorical | Lawvere + enriched categories | Topos theory, linear logic |
| Undecidability | Turing reduction + tropical encoding | Computability theory, optimization |

The unifying theme: **incompleteness phenomena are native to idempotent/tropical mathematics**, not merely imported from classical arithmetic. This suggests that any sufficiently rich tropical system — in optimization, verification, machine learning, or pure algebra — will encounter Gödelian barriers of its own.
