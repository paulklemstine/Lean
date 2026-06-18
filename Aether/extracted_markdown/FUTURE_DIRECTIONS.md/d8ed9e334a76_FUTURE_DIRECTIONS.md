# Future Directions: Tropical Myhill–Nerode Theory

## Overview

The tropical Myhill–Nerode theorem established here—recognizability of weighted languages over the min-plus semiring characterized by finite Nerode index and finite syntactic transition monoids—opens several major research avenues. Each direction below represents a concrete, actionable next step that builds directly on the formalized infrastructure.

---

## Direction 1: Tropical Hankel Rank Equals Nerode Index

**Statement.** For a weighted language $L : \Sigma^* \to \mathbb{N}_\infty$ recognized by a deterministic tropical automaton, the tropical Hankel rank (number of distinct rows of the infinite matrix $H_L(u,v) = L(u \cdot v)$) equals the Nerode index.

**Why this matters.** The Hankel matrix perspective connects automata minimization to tropical linear algebra and realization theory. In classical weighted automata over fields, the Fliess–Carlyle theorem identifies the minimal automaton dimension with the Hankel rank. A tropical analogue would bridge finite-state cost computation with tropical convexity and tropical polytope theory.

**Concrete formalization target:**
```
theorem tropical_hankel_rank_eq_nerode_index
    (L : List α → WithTop ℕ)
    (hfin : FiniteNerodeIndex L) :
    tropical_rank (hankelMatrix L) = Set.ncard (Set.range (Residual L))
```

**Key challenges.** Defining "tropical rank" of an infinite matrix requires tropical linear algebra infrastructure (tropical linear independence, tropical span). The deterministic case is simpler because row equality directly corresponds to residual equality without needing a full tropical basis theory.

**Impact.** Would unify automata minimization with tropical optimization, opening certified tropical realization algorithms.

---

## Direction 2: Shift-Invariant Nerode Theory for Non-Deterministic Weighted Automata

**Statement.** For weighted automata with transition costs (not just output costs), the correct Nerode equivalence is equality up to additive shift:
$$u \approx_L v \iff \exists c \in \mathbb{Z},\; \forall w,\; L(u \cdot w) = L(v \cdot w) + c.$$

The quotient by this equivalence gives a minimal weighted automaton with potential functions on states.

**Why this matters.** The strict residual-equality Nerode theorem proved here applies to deterministic output automata. Real-world weighted automata (shortest-path systems, probabilistic transducers, energy automata) have costs on transitions, not just outputs. The shift-invariant equivalence properly abstracts away state potentials, yielding a more general and structurally natural minimal automaton.

**Concrete formalization target:**
```
def ShiftNerodeEq (L : List α → WithTop ℕ) (u v : List α) : Prop :=
  ∃ c : ℤ, ∀ w, (L (u ++ w) : WithTop ℤ) = (L (v ++ w) : WithTop ℤ) + c

theorem shift_nerode_iff_weighted_recognizable
    (L : List α → WithTop ℕ) :
    WeightedRecognizable L ↔ FiniteShiftNerodeIndex L
```

**Key challenges.** The shift parameter $c$ lives in $\mathbb{Z}$ even when costs are in $\mathbb{N}_\infty$. Handling the interaction between $\top$ (infinity) and integer shifts requires careful case analysis. Well-definedness of transitions modulo shift requires proving that shift factors compose correctly.

**Impact.** Would extend the theory from deterministic output automata to the full class of weighted automata, covering shortest-path, min-cost flow, and energy game specifications.

---

## Direction 3: Tropical Eilenberg Correspondence

**Statement.** Establish a bijection between:
- Varieties of tropical weighted languages (closed under residuals, boolean combinations, and inverse morphisms), and
- Pseudovarieties of finite tropical transition monoids.

**Why this matters.** The classical Eilenberg correspondence is one of the deepest structural theorems in automata theory, classifying regular languages by their algebraic invariants. A tropical version would classify weighted languages by the structure of their syntactic monoids, enabling algebraic decidability results (e.g., "is this weighted language star-free?" becomes "is its syntactic monoid aperiodic?").

**Concrete formalization target:**
```
def TropicalVariety (V : Set (List α → WithTop ℕ)) : Prop := ...
def MonoidPseudovariety (C : ∀ (M : Type*), [Monoid M] → [Fintype M] → Prop) : Prop := ...

theorem tropical_eilenberg_correspondence :
    TropicalVariety V ↔ ∃ C, MonoidPseudovariety C ∧ 
      ∀ L, L ∈ V ↔ C (SyntacticMonoid L)
```

**Key challenges.** Defining tropical language varieties requires specifying the correct closure operations (tropical boolean combinations involve min/max, not just union/intersection). The monoid side needs tropical matrix semigroup theory. The proof requires a syntactic monoid functor that is natural with respect to morphisms.

**Impact.** Would create a classification program for weighted languages analogous to the Straubing–Thérien hierarchy, with applications to weighted temporal logic and quantitative verification.

---

## Direction 4: Certified Minimization Algorithms with Complexity Bounds

**Statement.** Implement and verify a polynomial-time algorithm for minimizing tropical DFAs, with a certified $O(n^2 \cdot |\Sigma| \cdot k)$ time bound where $n$ is the number of states and $k$ is the suffix depth needed to distinguish states.

**Why this matters.** The existence proof of the minimal automaton (via the Nerode construction) is non-constructive in the sense that it doesn't give an efficient algorithm. A verified minimization algorithm would enable certified compilation of weighted specifications, guaranteed-optimal controller synthesis, and verified shortest-path preprocessing.

**Concrete formalization target:**
```
def minimizeTropicalDFA (A : TropicalDFA α σ) [Fintype σ] [Fintype α] [DecidableEq σ] :
    { B : TropicalDFA α (Fin (nerodeIndex A)) // 
      recognizes B (languageOf A) ∧ isMinimal B }

theorem minimize_complexity [Fintype σ] [Fintype α] (A : TropicalDFA α σ) :
    timeComplexity (minimizeTropicalDFA A) ≤ 
      Fintype.card σ ^ 2 * Fintype.card α * suffixDepth A
```

**Key challenges.** The classical Hopcroft algorithm doesn't directly apply because tropical state equivalence requires checking infinitely many suffixes (in principle). The key insight is that suffix depth is bounded by $n-1$ for deterministic automata. Formalizing computational complexity within Lean requires a cost model.

**Impact.** Would enable verified optimization of routing tables, energy controllers, and scheduling policies with formal guarantees of optimality.

---

## Direction 5: Weighted MSO Characterization over Idempotent Semirings

**Statement.** A weighted language $L : \Sigma^* \to \mathbb{N}_\infty$ is tropically recognizable if and only if it is definable in weighted monadic second-order logic (wMSO) over the min-plus semiring.

**Why this matters.** The Büchi–Elgot–Trakhtenbrot theorem (regular = MSO-definable) is the cornerstone connecting automata to logic. Droste and Gastin extended this to weighted languages over arbitrary semirings. A formalized tropical instance would connect the Nerode theorem to logical definability, enabling specification of cost properties in temporal logic and model checking.

**Concrete formalization target:**
```
inductive TropicalWMSO (α : Type*) where
  | cost : (α → WithTop ℕ) → TropicalWMSO α
  | inf_sum : TropicalWMSO α → TropicalWMSO α → TropicalWMSO α
  | sup_prod : TropicalWMSO α → TropicalWMSO α → TropicalWMSO α
  | exists_pos : TropicalWMSO α → TropicalWMSO α
  | exists_set : TropicalWMSO α → TropicalWMSO α

theorem tropical_buchi_elgot :
    TropicalRecognizable L ↔ TropicalWMSO_Definable L
```

**Key challenges.** Defining the semantics of weighted MSO requires a careful treatment of quantifier semiring interactions. The tropical (min-plus) case has the special property that the semiring is idempotent, which simplifies some constructions but requires new arguments for others. The automata-to-logic direction needs Nerode theory; the logic-to-automata direction needs tropical product and projection constructions.

**Impact.** Would enable formal specification and verification of quantitative properties (worst-case cost, energy bounds, latency guarantees) using logical formulas, with automatic translation to minimal tropical automata.

---

## Summary Table

| Direction | Difficulty | Dependencies | Estimated Effort | Impact |
|-----------|-----------|-------------|-----------------|--------|
| 1. Hankel Rank | Medium | Tropical linear algebra | 2–4 weeks | High |
| 2. Shift-Invariant | Medium-Hard | WithTop ℤ arithmetic | 3–5 weeks | Very High |
| 3. Eilenberg | Hard | Variety theory, syntactic functors | 2–4 months | Transformative |
| 4. Certified Algorithms | Medium | Computational complexity model | 3–6 weeks | High (practical) |
| 5. Weighted MSO | Hard | wMSO semantics, product constructions | 2–4 months | Transformative |

Each direction builds on the infrastructure established here: the `TropicalDFA` structure, `Residual`/`NerodeEq` definitions, the recognizability characterization, and the minimality theorem. The formalization provides a solid foundation for any of these extensions.
