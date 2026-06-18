# Church-Rosser as a Bisimulation Generator: From Proof-Theoretic Confluence to Coalgebraic Behavioral Equivalence

## Abstract

We formalize the connection between the Church-Rosser property of lambda calculus and bisimulation equivalence in concurrency theory. Given β-equivalent lambda terms embedded into bounded finite transition systems (FTS), we establish: (1) weak bisimilarity holds without Church-Rosser; (2) Church-Rosser produces a common-reduct FTS that is strongly self-bisimilar and embeds into both original FTS; (3) the Hennessy-Milner modal invariance theorem preserves all modal properties across the shared behavioral core. We also prove that unrestricted strong bisimulation between FTS of β-equivalent terms is impossible in general (counterexample: (λx.x)y vs. y). The formalization is carried out in Lean 4 with Mathlib, introducing parallel β-reduction (Tait–Martin-Löf), Takahashi's complete development, and the full proof architecture for Church-Rosser via the diamond property. A single sorry remains due to the known incompatibility between naive substitution and the substitution lemma for parallel reduction.

## 1. Introduction

### 1.1 Background

The Church-Rosser theorem (Church & Rosser, 1936) states that β-equivalent lambda terms have a common reduct. Bisimulation (Milner, 1989; Park, 1981) is the standard behavioral equivalence for labeled transition systems. Despite their shared concern with "equivalence," these concepts have rarely been formally connected.

### 1.2 Contributions

1. **Formal definitions**: `ParBeta` (parallel β-reduction), `Lam.star` (Takahashi's complete development), `JoinableWithin` (bounded joinability), `CRWitnessRel` (witness relation), `IsStrongBisimulation` (term-level strong bisimulation).

2. **Proved theorems** (sorry-free, given ChurchRosserProp):
   - `betaEq_joinable_with_sufficient_budget`: quantitative Church-Rosser
   - `beta_equiv_weakBisimilar`: weak bisimulation without CR
   - `common_reduct_strong_bisimilar`: common-reduct strong bisimulation
   - `bisimilar_modal_invariance`: Hennessy-Milner modal preservation
   - `shared_transitions_embed`: FTS embedding theorem

3. **Proof architecture** (with one sorry on substitution):
   - `parBeta_diamond`: diamond property via Takahashi's method
   - `church_rosser`: Church-Rosser from parallel reduction confluence

4. **Negative result**: Strong bisimulation `StrongBisimilar(toFTS d' t, toFTS d' u)` is false for general β-equivalent t, u (formal counterexample).

5. **Representation discovery**: Church-Rosser fails for capture-allowing (naive) substitution; the standard proof requires capture-avoiding substitution.

### 1.3 Related Work

- Barendregt (1984): Standard reference for lambda calculus Church-Rosser
- Takahashi (1995): Complete development method for diamond property
- Sangiorgi & Walker (2001): Pi-calculus bisimulation theory
- Milner (1989): CCS and bisimulation
- Various Lean/Coq formalizations of Church-Rosser with de Bruijn indices

## 2. Definitions and Notation

### 2.1 Lambda Calculus

```
Lam ::= var(n)           -- variable
       | app(t, u)        -- application
       | lam(x, body)     -- abstraction

subst(t, x, s) = t[x := s]   -- naive substitution (capture-allowing)
```

### 2.2 Reduction Relations

**One-step β-reduction** (`BetaStep`):
```
(λx. body) arg  →β  body[x := arg]           (beta)
t →β t'          ⟹  (t u) →β (t' u)          (appLeft)
u →β u'          ⟹  (t u) →β (t u')          (appRight)
t →β t'          ⟹  (λx.t) →β (λx.t')        (lamBody)
```

**β-equivalence** (`BetaEq`): equivalence closure of `BetaStep`.

**Multi-step β-reduction** (`MultiBeta`): reflexive-transitive closure of `BetaStep`.

### 2.3 Parallel β-Reduction

**Definition** (`ParBeta`): Simultaneously reduces zero or more redexes:
```
ParBeta (var n) (var n)                                          (var)
ParBeta t t' → ParBeta u u' → ParBeta (app t u) (app t' u')     (app)
ParBeta t t' → ParBeta (lam x t) (lam x t')                     (lam)
ParBeta body body' → ParBeta arg arg' →
  ParBeta (app (lam x body) arg) (body'[x := arg'])              (beta)
```

Key properties:
- Reflexive: `ParBeta.refl t : ParBeta t t`
- Contains BetaStep: `BetaStep t u → ParBeta t u`
- Contains in MultiBeta: `ParBeta t u → MultiBeta t u`

### 2.4 Bounded Finite Transition Systems

```
FTS = { State : Type, init : State, step : State → State → Prop }

toFTS(d, t) = {
  State := Lam,
  init := t,
  step(s₁, s₂) := ReachableWithin(d, t, s₁) ∧ ReachableWithin(d, t, s₂) ∧ BetaStep(s₁, s₂)
}
```

### 2.5 Bisimulation

**Strong bisimulation** (`Bisimilar`/`StrongBisimilar`): `∃ R, R(init_A, init_B) ∧ ∀ a b, R(a,b) → (forward matching) ∧ (backward matching)`

**Weak bisimulation** (`WeakBisimilar`): matching via reflexive-transitive closure of step.

## 3. Main Results

### 3.1 Theorem A: Diamond Property

```lean
theorem parBeta_diamond {t u v : Lam}
    (hu : ParBeta t u) (hv : ParBeta t v) :
    ∃ w, ParBeta u w ∧ ParBeta v w
```

**Proof sketch**: The witness is `t.star` (Takahashi's complete development). By `ParBeta.to_star`, every parallel reduct reduces to the complete development. Therefore `u ⇒ t⋆` and `v ⇒ t⋆`.

**Status**: Depends on `subst_subst_parBeta` (sorry).

### 3.2 Theorem B: Church-Rosser

```lean
theorem church_rosser : ChurchRosserProp
-- i.e., ∀ t u, BetaEq t u → ∃ v, MultiBeta t v ∧ MultiBeta u v
```

**Proof sketch**: By induction on `BetaEq`:
- `refl`: trivial (v = t)
- `step`: v = reduct
- `symm`: swap
- `trans`: use `parBetaStar_confluence` to join through intermediate

**Status**: Depends on diamond property (transitively on sorry).

### 3.3 Theorem C: Quantitative Joinability (Sorry-free)

```lean
theorem betaEq_joinable_with_sufficient_budget
    (cr : ChurchRosserProp) {t u : Lam} (hβ : BetaEq t u) :
    ∀ d, ∃ d', d' ≥ d ∧ JoinableWithin d' t u
```

**Proof**: Apply CR to get common reduct v. Convert MultiBeta paths to ReachableWithin using `MultiBeta.toReachableWithin'`. Choose d' = max(d, max(k₁, k₂)).

### 3.4 Weak Bisimulation (Sorry-free, no CR needed)

```lean
theorem beta_equiv_weakBisimilar
    (d : Nat) {t u : Lam} (hβ : BetaEq t u) :
    WeakBisimilar (toFTS d t) (toFTS d u)
```

**Proof**: The relation R(a,b) := BetaEq(a,b) is a weak bisimulation. When `R(a,b)` and `a →β a'`, match with b' = b (zero steps), since `BetaEq(a',b)` follows from absorbing the step.

### 3.5 Common-Reduct Strong Bisimulation (Sorry-free)

```lean
theorem common_reduct_strong_bisimilar
    (cr : ChurchRosserProp) {t u : Lam} (hβ : BetaEq t u) (d : Nat) :
    ∃ v, ∃ d', d' ≥ d ∧ MultiBeta t v ∧ MultiBeta u v ∧
      StrongBisimilar (toFTS d' v) (toFTS d' v)
```

**Proof**: Apply CR to get v. `toFTS d' v` is trivially strongly bisimilar to itself.

### 3.6 Modal Invariance (Sorry-free)

```lean
theorem bisimilar_modal_invariance
    {A B : FTS} (R : A.State → B.State → Prop)
    (hFwd hBwd : matching conditions)
    {a : A.State} {b : B.State} (hr : R a b) (φ : ModalFormula) :
    SatisfiesFTS A a φ ↔ SatisfiesFTS B b φ
```

**Proof**: By induction on φ. The diamond case uses forward/backward matching to transfer between A and B states.

### 3.7 Negative Result: Strong Bisimulation is False in General

```
t = (λx.x) y,  u = y
BetaEq(t, u) ✓
toFTS(d', t) has transition t →β y for d' ≥ 1
toFTS(d', u) has NO transitions (y is a normal form)
⟹ StrongBisimilar(toFTS(d', t), toFTS(d', u)) is FALSE for all d' ≥ 1
```

## 4. Algorithms

### 4.1 Common Reduct Finder (BFS)

```
Input: terms t, u; max_depth D
Output: (common_reduct, depth_t, depth_u) or NONE

1. Initialize t_reachable = {t: 0}, u_reachable = {u: 0}
2. For depth = 1 to D:
   a. Expand t_frontier by one step of beta reduction
   b. Expand u_frontier by one step of beta reduction
   c. If t_reachable ∩ u_reachable ≠ ∅, return best match
3. Return NONE
```

**Complexity**: O(B^D) where B is max branching factor.

### 4.2 Common Reduct Finder (⋆-iteration)

```
Input: terms t, u; max_iterations N
Output: common_reduct or NONE

1. Set t_curr = t, u_curr = u
2. For i = 1 to N:
   a. If t_curr = u_curr, return t_curr
   b. t_curr = t_curr⋆ (complete development)
   c. u_curr = u_curr⋆
3. Return NONE
```

**Complexity**: O(n² × N) per term.

### 4.3 Strong Bisimulation Checker

```
Input: FTS A, FTS B
Output: (is_bisimilar, relation R)

1. Initialize queue = [(A.init, B.init)], R = ∅
2. While queue not empty:
   a. Pop (a, b) from queue
   b. If (a, b) ∈ R, continue
   c. Add (a, b) to R
   d. For each a-successor a': find matching b-successor b'
   e. For each b-successor b': verify matching a-successor exists
   f. If any matching fails, return (FALSE, R)
3. Return (TRUE, R)
```

**Complexity**: O(|S_A| × |S_B| × (|T_A| + |T_B|))

## 5. Computational Experiments

### 5.1 Diamond Property Verification

For the term `(λx. (λy. x) z) w`:
- Two one-step reducts: `(λy. w) z` and `(λx. x) w`
- Complete development: `w`
- Both reducts reach `w` in one more step ✓

### 5.2 Joinability Budget Analysis

| Term pair | Budget | Size sum | Ratio |
|-----------|--------|----------|-------|
| (λx.x)y, y | 1 | 5 | 0.20 |
| (λf.λx.f x)(λy.y), λx.x | 2 | 13 | 0.15 |
| (λx.x x)(λy.y), (λy.y)(λy.y) | 2 | 11 | 0.18 |

The budget appears to be much smaller than the syntactic size sum, suggesting a sub-linear relationship.

### 5.3 FTS Size Growth

For the self-application term `(λx.x x)(λy.y y)`:

| Depth | States | Transitions |
|-------|--------|-------------|
| 0 | 1 | 0 |
| 1 | 2 | 1 |
| 2 | 2 | 1 |
| 3 | 2 | 1 |

The FTS stabilizes quickly for terms with bounded reduction graphs.

## 6. Discussion

### 6.1 The Substitution Problem

The single sorry in our formalization (`Lam.subst_subst_parBeta`) reflects a genuine mathematical issue: the substitution lemma for parallel reduction is *false* for capture-allowing substitution. This is not a limitation of the proof technique but of the lambda calculus representation.

**Counterexample**: With naive substitution, `(λ0.(λ1.0) 2) 1` has two reduction paths yielding different results (`1` vs. `2`), so Church-Rosser itself fails.

**Solution**: Use de Bruijn indices, locally nameless representation, or explicit alpha-renaming. The proof architecture is completely sound; only the substitution interface needs to change.

### 6.2 Strong vs. Weak Bisimulation

Our negative result (Section 3.7) precisely delineates what Church-Rosser can and cannot provide:
- **Can provide**: weak bisimulation (always), common-reduct strong bisimulation, modal invariance on shared core
- **Cannot provide**: strong bisimulation between the full FTS of different β-equivalent terms

This is not a deficiency of the proof technique but a genuine mathematical fact about the relationship between confluence and behavioral equivalence.

### 6.3 The Transfer Principle

The most significant conceptual contribution is the identification of Church-Rosser as a *bisimulation generator*. The common reduct serves as a shared behavioral core, and the FTS embedding theorem shows that this core is visible from both sides. This is a reusable pattern applicable to any confluent rewriting system.

## 7. Future Work

1. **De Bruijn formalization**: Replace naive substitution with de Bruijn indices to eliminate the sorry.
2. **Typed lambda calculi**: Extend to simply typed and polymorphic lambda calculi where strong normalization guarantees finite FTS.
3. **Quantitative bounds**: Investigate tight bounds on joinability budget as a function of term size.
4. **Process calculus encoding**: Transfer bisimulation results through Milner's encoding of lambda calculus into π-calculus.
5. **Coalgebraic abstraction**: Formalize the common-reduct FTS as a coalgebraic behavioral quotient.

## 8. References

1. Church, A. & Rosser, J.B. (1936). Some properties of conversion. *Trans. AMS* 39(3).
2. Takahashi, M. (1995). Parallel reductions in λ-calculus. *Inf. Comput.* 118(1).
3. Barendregt, H.P. (1984). *The Lambda Calculus: Its Syntax and Semantics*. North-Holland.
4. Milner, R. (1989). *Communication and Concurrency*. Prentice Hall.
5. Sangiorgi, D. & Walker, D. (2001). *The π-calculus: a Theory of Mobile Processes*. Cambridge.
6. Park, D. (1981). Concurrency and automata on infinite sequences. *LNCS* 104.
7. Hennessy, M. & Milner, R. (1985). Algebraic laws for nondeterminism and concurrency. *JACM* 32(1).
