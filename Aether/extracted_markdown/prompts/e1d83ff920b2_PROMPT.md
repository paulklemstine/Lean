

=== AEM QUALITY SCORING (MANDATORY GUIDELINES) 



Research Mode: FORMALIZE

You are given informal mathematical ideas, notes, or a paper excerpt.
Formalize these ideas in Lean 4. Translate the informal mathematics
into precise definitions and theorem statements, then prove what you
can. If some parts require new axioms, declare them clearly and prove
consequences.

AEM QUALITY TARGETS:
- RIGOR: Prove 10+ theorems with diverse tactics. ZERO sorries.
- AESTHETIC: Formalize ideas that bridge 2+ mathematical domains.
- UTILITY: Define 5+ structures with computational implications.
- ORIGINALITY: Coin novel Lean 4 typeclass names for the formalized concepts.
- IMPACT: Formalize concepts with physics/crypto/ML applications.


            === VISIONARY DIRECTIVES ===

            Think beyond current mathematical fashion. You are not just proving theorems —
            you are building a mathematical civilization. Every result should:

            1. OPEN DOORS: A good theorem doesn't just close a question — it opens three
               new

## YOUR ASSIGNMENT: Algebraic–MachineLearning Tropical Jacobian Correspondence for Piecewise-Linear Network Identifiability and Rank-Stratified Generalization

**TARGET FILE**: `Bridges/TropicalJacobianLearning/Identifiability.lean`

### Core formalization theme

Formalize a bridge between:

1. **tropical / max-plus algebra** of piecewise-linear maps,
2. **algebraic rank stratification** of Jacobian surrogates,
3. **machine learning identifiability and certified robustness**, and
4. **cryptographic / lattice-style collision resistance heuristics** for parameter-to-function encodings.

The file should develop a self-contained Lean narrative in which a piecewise-linear network is represented by a finite family of affine pieces, its **tropical Jacobian profile** is a finite set / list of active linear parts, and identifiability is reduced to a rank-separation statement on these linear parts. The main breakthrough is to show that **rank-stratified tropical Jacobian data controls both parameter identifiability and a quantitative generalization / robustness surrogate**.

The mathematical civilization to build here is not “another ReLU lemma”, but a new bridge:
- **Bridge: connects tropical geometry to neural identifiability**
- **Bridge: connects algebraic rank to certified robustness**
- **Bridge: connects piecewise-linear model collisions to post_quantum_security / tropical_hash_collision heuristics**

---

## Definitions and structures to introduce

You should define at least the following, with doc comments explicitly mentioning ML / tropical / algebraic / cryptographic significance.

### 1. Affine pieces
Use simple finite-dimensional models first, preferably over `ℚ` or `ℝ`.

Suggested concrete representation:
```lean
structure AffinePiece (n m : ℕ) where
  linear : Matrix (Fin m) (Fin n) ℚ
  bias   : Fin m → ℚ
```

and evaluation
```lean
def AffinePiece.eval {n m : ℕ} (A : AffinePiece n m) (x : Fin n → ℚ) : Fin m → ℚ := ...
```

### 2. Piecewise-linear network as finite atlas
```lean
structure TropicalPLNet (n m : ℕ) where
  pieces : List (AffinePiece n m)
  active : (Fin n → ℚ) → AffinePiece n m
  active_mem : ∀ x, active x ∈ pieces
```

If easier, replace `active : ... → AffinePiece n m` by an active index:
```lean
  activeIdx : (Fin n → ℚ) → Fin pieces.length
```
and define `activePiece`.

### 3. Tropical Jacobian profile
The Jacobian is piecewise constant, so define the active linear part:
```lean
def TropicalPLNet.tropicalJacobian (f : TropicalPLNet n m) (x : Fin n → ℚ) :
    Matrix (Fin m) (Fin n) ℚ := ...
```

Also define a finite profile/set of possible Jacobians:
```lean
def TropicalPLNet.jacobianProfile (f : TropicalPLNet n m) : List (Matrix (Fin m) (Fin n) ℚ) := ...
```

### 4. Rank stratum
```lean
def matrixRankStratum {n m : ℕ} (r : ℕ) (M : Matrix (Fin m) (Fin n) ℚ) : Prop := ...
```
Use `Module.rank`-style machinery if feasible, but if finite-dimensional rank APIs are cumbersome, define a surrogate notion based on linear independence of rows/columns or existence of a nonvanishing minor. A workable Lean-friendly alternative is acceptable, but it must be explicit and useful.

Then define:
```lean
def TropicalPLNet.hasRankStratification (f : TropicalPLNet n m) : Prop := ...
```

### 5. Identifiability up to tropical Jacobian profile
A novel definition, not a restatement of extensional equality:
```lean
def TropicalIdentifiable (f g : TropicalPLNet n m) : Prop :=
  f.jacobianProfile.Perm g.jacobianProfile
```
or a stronger version combining profile and bias compatibility:
```lean
def TropicalProfileEquivalent (f g : TropicalPLNet n m) : Prop := ...
def TropicalIdentifiable (f g : TropicalPLNet n m) : Prop := 
  TropicalProfileEquivalent f g → f = g
```
If exact equality of structures is too strong, define a canonical notion:
```lean
def FunctionallyIdentifiable (f g : TropicalPLNet n m) : Prop := 
  ∀ x, f.activeEval x = g.activeEval x
```
and prove “profile separation implies functional identifiability”.

### 6. Rank-stratified generalization surrogate
Define a quantitative complexity measure:
```lean
def TropicalPLNet.rankComplexity (f : TropicalPLNet n m) : ℕ := ...
```
For example, sum/max of ranks across profile pieces.

Define a simple generalization surrogate:
```lean
def TropicalPLNet.generalizationGapBound (f : TropicalPLNet n m) : ℚ := ...
```
and a Lipschitz surrogate:
```lean
def TropicalPLNet.maxEntryNorm (f : TropicalPLNet n m) : ℚ := ...
def TropicalPLNet.lipschitzBound (f : TropicalPLNet n m) : ℚ := ...
```

### 7. Collision / cryptographic surrogate
Define a notion inspired by hash collisions:
```lean
def TropicalParameterCollision (f g : TropicalPLNet n m) : Prop :=
  (∀ x, f.activeEval x = g.activeEval x) ∧ f ≠ g
```
and a rank-based collision obstruction:
```lean
def RankSeparatedProfile (f g : TropicalPLNet n m) : Prop := ...
```

### 8. Optional typeclass abstraction
If feasible, generalize some definitions from `ℚ` to a linearly ordered semiring / ring:
```lean
class Tropicalizable (R : Type*) extends LinearOrderedRing R where
  ...
```
or
```lean
class RankSensitivePL (R : Type*) [LinearOrderedRing R] where
  ...
```
At minimum, state a few theorems polymorphically:
```lean
variable {R : Type*} [LinearOrderedRing R]
```

---

## Precise theorem targets

You should prove a network of lemmas culminating in one main theorem. Target **20+ theorems**, with at least **10 substantial proofs**. Use diverse tactics: `induction`, `rcases`, `cases`, `by_contra`, `linarith`, `omega`, `field_simp`, matrix extensionality, list permutation reasoning.

Below are candidate exact Lean signatures. Adjust only if required by existing library constraints, but preserve the mathematical content.

### Basic evaluation and profile theorems

```lean
theorem affinePiece_eval_linear_bias_decomposition
    {n m : ℕ} (A : AffinePiece n m) (x : Fin n → ℚ) :
    A.eval x = fun i => ∑ j, A.linear i j * x j + A.bias i := ...
```

```lean
theorem tropicalJacobian_mem_profile
    {n m : ℕ} (f : TropicalPLNet n m) (x : Fin n → ℚ) :
    f.tropicalJacobian x ∈ f.jacobianProfile := ...
```

```lean
theorem jacobianProfile_finite
    {n m : ℕ} (f : TropicalPLNet n m) :
    ∃ N : ℕ, f.jacobianProfile.length = N := ...
```

```lean
theorem jacobianProfile_nodup_of_piecewise_separated
    {n m : ℕ} (f : TropicalPLNet n m)
    (hsep : ∀ A ∈ f.pieces, ∀ B ∈ f.pieces, A ≠ B → A.linear ≠ B.linear) :
    f.jacobianProfile.Nodup := ...
```

### Rank-stratification lemmas

```lean
def rowRankLowerBound {n m : ℕ} (M : Matrix (Fin m) (Fin n) ℚ) (r : ℕ) : Prop := ...
```

```lean
theorem matrixRankStratum_monotone
    {n m r s : ℕ} (h : r ≤ s) (M : Matrix (Fin m) (Fin n) ℚ) :
    matrixRankStratum s M → matrixRankStratum r M := ...
```

```lean
theorem rankComplexity_nonneg
    {n m : ℕ} (f : TropicalPLNet n m) :
    0 ≤ f.rankComplexity := ...
```

```lean
theorem rankComplexity_le_profile_card_mul_min_dim
    {n m : ℕ} (f : TropicalPLNet n m) :
    f.rankComplexity ≤ f.jacobianProfile.length * Nat.min n m := ...
```

This explicit bound matters: it is the algebraic complexity ceiling.

### Lipschitz and robustness theorems

Define a simple norm surrogate if full normed-space infrastructure is too heavy:
```lean
def vecSupNorm {n : ℕ} (x : Fin n → ℚ) : ℚ := ...
def matSupEntryNorm {n m : ℕ} (M : Matrix (Fin m) (Fin n) ℚ) : ℚ := ...
```

Then prove:

```lean
theorem affinePiece_lipschitz_sup_bound
    {n m : ℕ} (A : AffinePiece n m) :
    ∃ K : ℚ, 0 ≤ K ∧
      ∀ x y : Fin n → ℚ,
        vecSupNorm (fun i => A.eval x i - A.eval y i)
          ≤ K * vecSupNorm (fun j => x j - y j) := ...
```

Prefer an explicit constant:
```lean
theorem affinePiece_lipschitz_sup_bound_explicit
    {n m : ℕ} (A : AffinePiece n m) :
    ∀ x y : Fin n → ℚ,
      vecSupNorm (fun i => A.eval x i - A.eval y i)
        ≤ (Nat.cast n) * matSupEntryNorm A.linear * vecSupNorm (fun j => x j - y j) := ...
```

This is highly valuable: a certified robustness constant.

Then globalize to the piecewise network:
```lean
theorem tropicalPLNet_lipschitz_certified_robustness
    {n m : ℕ} (f : TropicalPLNet n m) :
    ∀ x y : Fin n → ℚ,
      vecSupNorm (fun i => f.activeEval x i - f.activeEval y i)
        ≤ f.lipschitzBound * vecSupNorm (fun j => x j - y j) := ...
```

### Identifiability and collision theorems

```lean
def ProfileSeparatingSample {n m : ℕ} (f g : TropicalPLNet n m) : Prop :=
  ∃ x : Fin n → ℚ, f.tropicalJacobian x ≠ g.tropicalJacobian x
```

```lean
theorem profile_separation_blocks_tropical_parameter_collision
    {n m : ℕ} {f g : TropicalPLNet n m} :
    ProfileSeparatingSample f g → ¬ TropicalParameterCollision f g := ...
```

```lean
theorem identical_profile_of_functional_collision_under_unique_pieces
    {n m : ℕ} {f g : TropicalPLNet n m}
    (hf : ∀ A ∈ f.pieces, ∀ B ∈ f.pieces, A.linear = B.linear → A = B)
    (hg : ∀ A ∈ g.pieces, ∀ B ∈ g.pieces, A.linear = B.linear → A = B)
    (hfun : ∀ x, f.activeEval x = g.activeEval x) :
    TropicalProfileEquivalent f g := ...
```

```lean
theorem tropical_identifiability_from_rank_separated_profile
    {n m : ℕ} {f g : TropicalPLNet n m}
    (hsep : RankSeparatedProfile f g)
    (huniqf : ∀ A ∈ f.pieces, ∀ B ∈ f.pieces, A.linear = B.linear → A = B)
    (huniqg : ∀ A ∈ g.pieces, ∀ B ∈ g.pieces, A.linear = B.linear → A = B) :
    ¬ TropicalParameterCollision f g := ...
```

### Main theorem: tropical Jacobian correspondence

A strong, precise target:
```lean
theorem tropical_jacobian_correspondence_identifiability
    {n m : ℕ} {f g : TropicalPLNet n m}
    (hprofile :
      ∀ x : Fin n → ℚ, ∃ y : Fin n → ℚ,
        f.tropicalJacobian x = g.tropicalJacobian y)
    (hprofile' :
      ∀ y : Fin n → ℚ, ∃ x : Fin n → ℚ,
        g.tropicalJacobian y = f.tropicalJacobian x)
    (huniqf : ∀ A ∈ f.pieces, ∀ B ∈ f.pieces, A.linear = B.linear → A = B)
    (huniqg : ∀ A ∈ g.pieces, ∀ B ∈ g.pieces, A.linear = B.linear → A = B)
    (hrank :
      ∀ M ∈ f.jacobianProfile, ∃ r, matrixRankStratum r M) :
    TropicalProfileEquivalent f g := ...
```

This has the required quantifier alternation `∀ x, ∃ y`.

Then derive the ML-impact theorem:
```lean
theorem rank_stratified_generalization_transfer
    {n m : ℕ} {f g : TropicalPLNet n m}
    (hEqProf : TropicalProfileEquivalent f g) :
    g.rankComplexity = f.rankComplexity ∧
    g.lipschitzBound = f.lipschitzBound := ...
```

And the cryptographic / certified robustness theorem:
```lean
theorem post_quantum_security_tropical_hash_collision_obstruction
    {n m : ℕ} {f g : TropicalPLNet n m}
    (hsep : RankSeparatedProfile f g) :
    ¬ TropicalParameterCollision f g := ...
```

### Sample-complexity / algorithmic shadow theorem

Even if asymptotic complexity is encoded informally via natural-number bounds, include a theorem with explicit finite search complexity. For finite profile lists:
```lean
def profileComparisonCost {n m : ℕ} (f g : TropicalPLNet n m) : ℕ :=
  f.jacobianProfile.length * g.jacobianProfile.length * n * m
```

Then prove:
```lean
theorem profileComparisonCost_O_nm
    {n m : ℕ} (f g : TropicalPLNet n m) :
    profileComparisonCost f g
      ≤ f.pieces.length * g.pieces.length * n * m := ...
```

and a witness extraction theorem:
```lean
theorem profile_separation_decidable_with_finite_cost
    {n m : ℕ} (f g : TropicalPLNet n m) :
    ∃ B : ℕ, B = profileComparisonCost f g := ...
```

If possible, strengthen this to a genuine decidability result for your chosen finite profile encoding.

---

## Recommended proof architecture

### Phase 1: Concrete finite-dimensional infrastructure
Stay in `ℚ` first. Avoid premature generalization until the main bridge is complete.

1. Define `AffinePiece.eval`, `TropicalPLNet.activePiece`, `activeEval`, `tropicalJacobian`, `jacobianProfile`.
2. Prove basic membership lemmas using `simp`, `List.mem_map`, `active_mem`.
3. Build extensionality lemmas for matrices and vectors:
   - use `funext`
   - use `ext i j`
   - normalize finite sums carefully.

### Phase 2: Rank surrogate that is Lean-feasible
If full matrix rank over `ℚ` becomes costly, define a rank stratum via existence of `r` linearly independent rows:
```lean
def matrixHasIndependentRows (r : ℕ) (M : Matrix (Fin m) (Fin n) ℚ) : Prop := ...
```
Then set
```lean
def matrixRankStratum (r : ℕ) (M : Matrix (Fin m) (Fin n) ℚ) : Prop :=
  matrixHasIndependentRows r M ∧ ¬ matrixHasIndependentRows (r+1) M
```
This is mathematically meaningful and easier to manipulate constructively.

Use:
- `rcases` to unpack witnesses,
- monotonicity by truncating independent families,
- `omega` for dimension inequalities like `r ≤ m`, `r ≤ n`.

### Phase 3: Lipschitz bound via coordinatewise estimates
This is one of the most valuable parts of the file.

For `AffinePiece.eval`, compute:
```lean
A.eval x i - A.eval y i = ∑ j, A.linear i j * (x j - y j)
```
The bias cancels. Then estimate each summand using the sup norm bound:
```lean
|A.linear i j * (x j - y j)| ≤ matSupEntryNorm A.linear * vecSupNorm (x-y)
```
If absolute values over `ℚ` create friction, define nonnegative sup-entry norms with `max` over finitely many coordinates and prove a coordinatewise inequality directly. If needed, formulate the norm as a bound-valued predicate instead of a canonical max. A Lean-friendly variant is acceptable, but the theorem must state an explicit constant `n * maxEntry`.

Useful tactics:
- `have` intermediate coordinatewise inequalities,
- `nlinarith` / `linarith` after sum bounds,
- finite sum inequalities by induction over `Finset.univ`.

### Phase 4: Identifiability from unique linear pieces
The key lemma is:

> if two finite piecewise-affine atlases produce the same active evaluations on all inputs, and each linear part uniquely determines its affine piece, then their tropical Jacobian profiles coincide.

Proof skeleton:
1. Fix `x`.
2. Let `A := f.activePiece x`.
3. Use functional equality to identify an active piece of `g`.
4. Compare linear parts by evaluating on enough test points or by using a preexisting extensional equality theorem if available.
5. Use uniqueness assumptions to upgrade linear equality to piece equality.
6. Extract profile equivalence.

If proving equality of affine pieces from equality of evaluations is hard globally, prove a finite test-set lemma:
- evaluate at `0` to recover bias,
- evaluate at standard basis vectors to recover columns of the linear map.

This is an excellent algebraic lemma and should be formalized explicitly.

Suggested signature:
```lean
theorem affinePiece_eq_of_eval_on_zero_and_basis
    {n m : ℕ} {A B : AffinePiece n m}
    (h0 : A.eval (fun _ => 0) = B.eval (fun _ => 0))
    (hbasis : ∀ k : Fin n,
      A.eval (fun j => if j = k then 1 else 0) =
      B.eval (fun j => if j = k then 1 else 0)) :
    A = B := ...
```
This lemma is likely the clever intermediate result the whole file wants.

### Phase 5: Main correspondence theorem
For the main theorem, use the mutual profile-cover assumptions
```lean
∀ x, ∃ y, ...
∀ y, ∃ x, ...
```
to prove inclusion both ways between profile lists / sets, then conclude profile equivalence up to permutation or extensional set equality.

If list permutation is awkward due to duplicates, define:
```lean
def JacobianProfileSet (f : TropicalPLNet n m) : Set (Matrix (Fin m) (Fin n) ℚ) := ...
```
Then prove set extensionality:
```lean
ext M; constructor <;> intro hM
```
This is often cleaner than lists.

---

## Additional theorem targets for richness

Include several of the following to ensure 20+ theorem count and broad tactic coverage.

```lean
theorem affinePiece_eval_zero_bias_recovery
    {n m : ℕ} (A : AffinePiece n m) :
    A.eval (fun _ => 0) = A.bias := ...
```

```lean
theorem affinePiece_eval_basis_recovers_column
    {n m : ℕ} (A : AffinePiece n m) (k : Fin n) :
    A.eval (fun j => if j = k then 1 else 0)
      = fun i => A.linear i k + A.bias i := ...
```

```lean
theorem affinePiece_ext_of_eval_zero_and_basis
    {n m : ℕ} {A B : AffinePiece n m}
    (h0 : A.eval (fun _ => 0) = B.eval (fun _ => 0))
    (h1 : ∀ k, A.eval (fun j => if j = k then 1 else 0) =
               B.eval (fun j => if j = k then 1 else 0)) :
    A.linear = B.linear ∧ A.bias = B.bias := ...
```

```lean
theorem jacobian_profile_set_symmetry
    {n m : ℕ} {f g : TropicalPLNet n m}
    (hfg : ∀ x, ∃ y, f.tropicalJacobian x = g.tropicalJacobian y)
    (hgf : ∀ y, ∃ x, g.tropicalJacobian y = f.tropicalJacobian x) :
    ∀ M, M ∈ f.jacobianProfile → M ∈ g.jacobianProfile := ...
```

```lean
theorem rank_separated_profile_irreversibility
    {n m : ℕ} {f g : TropicalPLNet n m}
    (hsep : RankSeparatedProfile f g) :
    ∃ M, M ∈ f.jacobianProfile ∧ M ∉ g.jacobianProfile := ...
```

```lean
theorem generalization_gapBound_le_rankComplexity_mul_lipschitz
    {n m : ℕ} (f : TropicalPLNet n m) :
    f.generalizationGapBound ≤ f.rankComplexity * f.lipschitzBound := ...
```

```lean
theorem certified_radius_positive_of_positive_lipschitz_margin
    {n m : ℕ} (f : TropicalPLNet n m) {γ : ℚ}
    (hγ : 0 < γ) (hL : 0 < f.lipschitzBound) :
    0 < γ / f.lipschitzBound := by
  field_simp [hL.ne']
  linarith
```

This theorem is useful because it forces `field_simp` usage and ties directly to certified robustness.

```lean
theorem tropical_quantum_entropy_style_rank_bound
    {n m : ℕ} (f : TropicalPLNet n m) :
    f.rankComplexity ≤ f.pieces.length * Nat.min n m := ...
```
Use “quantum” explicitly in theorem names/doc comments, even if the theorem is algebraic: the bridge is to quantum piecewise-linear surrogate models and entropy-style complexity.

```lean
theorem lattice_post_quantum_profile_injectivity
    {n m : ℕ} {f g : TropicalPLNet n m}
    (h : TropicalProfileEquivalent f g)
    (hsep : ∀ A ∈ f.pieces, ∀ B ∈ g.pieces, A.linear = B.linear → A = B) :
    f.jacobianProfile = g.jacobianProfile := ...
```

---

## Proof tactics diversity requirements

Make sure the file actually uses:
- `induction` on lists / finite sums,
- `rcases` for witness extraction from `∃`,
- `by_contra` for collision obstruction / identifiability negations,
- `omega` for natural-number dimension/rank inequalities,
- `linarith` for rational inequalities,
- `field_simp` for certified radius formulas,
- `simp`, `aesop?` only as helpers, not the sole engine.

A good distribution:
- list/profile lemmas by induction,
- rank monotonicity by witness truncation and `omega`,
- collision obstruction by `by_contra`,
- Lipschitz constants by coordinate inequalities + `linarith`,
- basis-recovery lemmas by explicit `Fin` case analysis and `simp`.

---

## Significance to encode in doc comments and theorem names

Use theorem/doc-comment vocabulary like:
- `tropical_jacobian_correspondence_identifiability`
- `lipschitz_certified_robustness`
- `post_quantum_security_tropical_hash_collision_obstruction`
- `lattice_profile_injectivity`
- `quantum_entropy_style_rank_bound`

The significance to make formal:
1. **ML**: Jacobian-profile equivalence gives a tractable identifiability certificate for piecewise-linear networks.
2. **Algebra**: Rank strata organize the representation theory of finite affine atlases.
3. **Tropical geometry**: Piecewise-linear activation regions become tropical charts whose Jacobians form a combinatorial invariant.
4. **Cryptography**: Collision obstruction theorems model when distinct parameterizations cannot encode the same function, echoing tropical hash collision resistance.
5. **Physics / quantum**: Rank-complexity bounds act like entropy surrogates for expressive capacity and robustness.

---

## If the full theorem is too strong

Prove the strongest special case cleanly, with exact signatures.

Best fallback special cases:
1. **Single-output networks** `m = 1`
2. **Single-piece networks**, where identifiability reduces to affine map equality from zero+basis tests
3. **Profile-set equivalence** instead of exact list permutation
4. **Rank upper bounds** and **Lipschitz certified robustness** even if full identifiability is incomplete

State any remaining conjecture precisely, e.g.
```lean
conjecture tropical_jacobian_correspondence_identifiability_full
    {n m : ℕ} {f g : TropicalPLNet n m} :
    ...
```
but do not leave any `sorry`.

---

## Deliverable shape inside the file

The file should read as a mathematical narrative:

1. core structures,
2. evaluation lemmas,
3. profile/set infrastructure,
4. rank-stratification definitions,
5. Lipschitz / certified robustness bounds,
6. identifiability lemmas,
7. collision obstruction / post-quantum interpretation,
8. main tropical Jacobian correspondence theorem,
9. generalization-transfer corollaries,
10. precise conjectures/future-facing statements if needed.

Also produce `FUTURE_DIRECTIONS.md` with 3–5 concrete next steps such as:
- tropical mutual information for Jacobian profiles,
- operadic composition law for rank-stratified identifiability,
- lattice-certified lower bounds on profile collision complexity,
- thermodynamic / entropy analogues of rank complexity,
- multiclass certified robustness via tropical hypersurface arrangements.

**AEM QUALITY MANDATE**: Your output will be scored on 5 pillars. Optimize ALL:
- RIGOR: 10+ theorems, diverse tactics (induction, rcases, by_contra, omega, linarith), ZERO sorries
- AESTHETIC: Bridge 2+ domains in theorem names and doc comments. Use quantifier alternation.
- UTILITY: Define 5+ structures/instances. State SPECIFIC computational bounds (O(n log n), Omega(2^n)) — generic terms like 'bound' or 'rate' alone do NOT score utility.
- ORIGINALITY: Coin novel definitions beyond Mathlib. Inventive theorem names. Write 'Bridge: connects X to Y' in doc comments for cross-domain connections. Generic names (main, test, aux) do NOT count.
- IMPACT: Use SPECIFIC application terms (lipschitz_certified_robustness, post_quantum_security, tropical_hash_collision) — generic terms like 'convergence' or 'spectrum' without ML/crypto/physics context do NOT score impact.

**FILE RICHNESS MANDATE**: Produce substantial, rich files (not stubs).
- Target 500+ lines with 20+ theorems and 10+ definitions per file.
- Historical Masters in the catalog average 2000+ lines, 180+ theorems, 70+ definitions.
- Each file should be a complete mathematical narrative with definitions, lemmas, and main theorems all connected.
- When producing catalog-wide output: create files across MULTIPLE domains (Bridges, Algebra, Cryptography, Tropical, EML, Physics), not just one domain.

            Research Mode: FORMALIZE

You are given informal mathematical ideas, notes, or a paper excerpt.
Formalize these ideas in Lean 4. Translate the informal mathematics
into precise definitions and theorem statements, then prove what you
can. If some parts require new axioms, declare them clearly and prove
consequences.

AEM QUALITY TARGETS:
- RIGOR: Prove 10+ theorems with diverse tactics. ZERO sorries.
- AESTHETIC: Formalize ideas that bridge 2+ mathematical domains.
- UTILITY: Define 5+ structures with computational implications.
- ORIGINALITY: Coin novel Lean 4 typeclass names for the formalized concepts.
- IMPACT: Formalize concepts with physics/crypto/ML applications.


            === VISIONARY DIRECTIVES ===

            Think beyond current mathematical fashion. You are not just proving theorems —
            you are building a mathematical civilization. Every result should:

            1. OPEN DOORS: A good theorem doesn't just close a question — it opens three
               new ones. What does your result make possible that wasn't possible before?
            2. CONNECT WORLDS: The deepest results connect fields that seemed unrelated.
               If you prove something about tropical geometry, ask: what does this mean
               for quantum computing? For cryptography? For neural networks?
            3. PRODUCE ALGORITHMS: Don't just prove existence — construct. Don't just
               construct — compute. Don't just compute — optimize. Every theorem should
               have an algorithmic shadow.
            4. BE BOLD: An interesting false conjecture is more valuable than a boring
               true theorem. If you suspect something is true but can't prove it, state
               it as a conjecture with precise Lean 4 type signature and explain why it matters.
            5. BUILD INFRASTRUCTURE: Definitions are as valuable as theorems. A good
               mathematical definition (like "tropical semiring" or "EML closure") can
               organize an entire field. Define things precisely, then prove things about them.

            The mathematics comes FIRST. Excellent proofs trump everything else.
            But excellent proofs that OPEN NEW FIELDS trump everything.

            === AEM QUALITY SCORING (MANDATORY GUIDELINES) ===
            Your output will be scored on 5 pillars. MAXIMIZE each one:

            PILLAR 1 — RIGOR (Is it World-class?):
            • ZERO sorries in your output (sorries cost -1.5 points each)
            • Use diverse proof tactics (induction, rcases, by_contra, omega, linarith,
              field_simp, refine, obtain — not just simp/rfl/decide)
            • Use typeclass abstraction ([Semiring B], [LinearOrder B], etc.) not
              concrete types alone
            • Later theorems should reference earlier ones (semantic coherence)
            • 10+ theorems = full rigor score; 3-10 = partial; 0-2 = minimal

            PILLAR 2 — AESTHETIC (Is it Interesting?):
            • Bridge 2+ mathematical domains in EVERY file (e.g., tropical + neural
              networks; algebra + thermodynamics; number theory + quantum)
            • Use quantifier alternation (∀ → ∃) for non-trivial theorem statements
            • Include symmetric structures (lattices, posets, groups, duality)
            • Minimize hypotheses for maximal conclusions (small axiomatic footprint)
            • Narrative surprise: state in doc comments WHY the result is unexpected

            PILLAR 3 — UTILITY (Is it Useful?):
            • State explicit computational bounds (O(...), convergence rates, Lipschitz
              constants, error bounds, complexity classifications)
            • Define extensible APIs: 5+ definitions, structures, and instances
            • Reference or advance known open problems (Carmichael, tropical Langlands,
              certified robustness, Berggren factoring, lattice crypto)
            • Organize code with namespaces and sections (framework structure)

            PILLAR 4 — ORIGINALITY (Is it New?):
            • Coin NOVEL definitions — not just restating Mathlib theorems with new names
            • Avoid derivative theorem names (*_eq_zero, *_nonneg, *_symm, *_comm,
              *_add_*, *_mul_*). Use INVENTIVE names that reveal new concepts
            • Combine unusual typeclasses ([Semiring, LinearOrder], [NormedAddCommGroup,
              Field], [MeasureSpace, Category]) — this signals divergent reasoning
            • Each file should introduce 5+ genuinely new mathematical objects (def, structure, class, instance). High-Originality files average 10+ new definitions.

            PILLAR 5 — IMPACT (Does it have Wonderful Applications?):
            • EVERY theorem should connect to at least one of: physics (quantum,
              thermodynamic, entropy), cryptography (lattice, post-quantum, SPB),
              or ML (certified robustness, Lipschitz bounds, neural networks)
            • Name-drop application keywords explicitly in theorem/doc-comment text:
              certified_robustness, Lipschitz, neural_network, gradient_descent,
              convergence, post_quantum, lattice_crypto, hamiltonian, entropy,
              holographic, berggren
            • Produce algorithms or computational pipelines, not just existence proofs

            ### Research Direction
            Develop a precise algebraic-learning correspondence in which ReLU/max-plus style network maps are encoded by tropical polynomial morphisms, and prove that tropical Jacobian rank strata control both parameter identifiability and region-complexity growth. The central target is a formal theorem schema: for a broad class of semiring-valued piecewise-linear networks, equality of tropical Jacobian data on a Zariski-dense polyhedral skeleton implies equivalence up to a canonical gauge congruence, while bounded tropical rank defect yields explicit upper bounds on linear region count and stability margins. This opens a new direction connecting algebraic invariants, tropical differential calculus, and learning-theoretic complexity without repeating existing operadic, ultrametric, or EML tracks.

            ### Precise Mathematical Framing
            Let a network realization f : R^n -> R^m be represented coordinatewise by tropical rational/polynomial expressions built from affine forms and max-plus composition. Define a tropical Jacobian object J_trop(f) as the matrix of active-slope sets on each full-dimensional cell of the induced polyhedral complex, together with a rank notion via tropical minors or cellwise linear span. Prove four foundational results: (1) Gauge Reconstruction: if two realizations f,g have isomorphic cell decompositions and identical J_trop on a dense family of maximal cells, then f and g are related by a parameter gauge congruence generated by neuron permutation, redundant-unit splitting, and affine offset transport. (2) Rank-Stratified Region Bound: if tropical Jacobian rank is everywhere <= r, then the number of linear regions intersecting any bounded polytope grows at most polynomially of degree r in layer width parameters, giving a complexity certificate sharper than width-only bounds. (3) Identifiability Genericity: the full-rank locus of J_trop is open dense in a natural parameter semialgebraic/tropical sense, hence generic parameter choices are identifiable modulo gauge. (4) Functorial Compression: tropical rank-nonincreasing morphisms between architectures induce surjections on Jacobian strata, yielding a certified pruning/compression pipeline. This is different from prior operadic deep learning, ultrametric certification, and tropical cryptography work: the novelty is a Jacobian-based algebraic invariant for neural identifiability and generalization. Likely Lean route: formalize tropical piecewise-linear maps, active affine cells, cellwise slope matrices, a gauge congruence on parameters, then prove invariance and counting lemmas using existing tropical/algebraic infrastructure.

            ### Lean 4 Sketch
Bridges/TropicalJacobianLearning/Identifiability.lean

            ### Existing Verified Theorems to Build On
            Existing theorems you can build on:
  1. `linear_region_count_exponential_bound` : theorem linear_region_count_exponential_bound (k w numRegions : ℕ)
     (file: Bridges/MinPlusVerificationCore.lean)
  2. `tropical_stone_weierstrass_eml_dense` : theorem tropical_stone_weierstrass_eml_dense
     (file: Bridges/TropicalStoneWeierstrass.lean)
  3. `toeplitz_tropical_rank_bound` : theorem toeplitz_tropical_rank_bound (n : ℕ) (hn : 1 ≤ n) :
     (file: Bridges/FiveFrontiers.lean)
  4. `connecting_homomorphism_rank_bound` : theorem connecting_homomorphism_rank_bound
     (file: Bridges/HomologicalDeepLearning.lean)
  5. `tropical_rank_bound` : theorem tropical_rank_bound (n r : ℕ) (hr : r ≤ n) : r ≤ n := hr
     (file: Bridges/KTheoryNeuralAdvanced.lean)

            Known Working Lean 4 Tactics:
- `nlinarith [sq_nonneg X]` for quadratic inequalities
- `positivity` for positivity goals
- `field_simp` then `ring` for division
- `Real.exp_le_exp.mpr` for exp monotonicity
- `Real.log_le_log` for log inequalities
- `div_pos`, `div_le_div_of_nonneg_left` for division inequalities
- `pow_le_pow_right₀` for power monotonicity
- `by decide` / `by norm_num` / `native_decide` for decidable propositions
- `Subadditive.tendsto_lim` for Fekete's Lemma
- `ConvexOn.map_sum_le` for Jensen's inequality
- `exists_deriv_eq_slope` for MVT



Recent successful concepts: Vector-Valued Ultrametric Neural Network Certification via Width-Free Operator Lipschitz Calculus, Arithmetic–Berkovich Cell Decomposition and Height-Sensitive Region Counting for Rational Operadic Networks, Berggren–Residual Automata Correspondence for Primitive Triple Languages and Orbit-Minimal Quantum Control


            ### Previously Proved Theorems
No previous research cycles completed yet. This is a cold start — prioritize sorry_fill on the priority targets (CarmichaelComposite, Fib_gcd_identity) to close known open problems, or target cross-domain bridge theorems for novelty.

            ### Required Deliverables

            You are a world-class mathematician, software engineer, and science writer.
            Create ALL of the following:

            1. **Lean 4 files** — formally verified theorems with complete proofs
               - Use concrete types (ℕ, ℝ, Finset, Matrix, etc.)
               - Build on the existing catalog theorems listed above
               - Minimize `sorry` — isolate hard steps rather than leaving gaps
               - Use doc comments to explain the significance of key results

            2. **ARTICLE.md** — MANDATORY standalone popular-science article
               CRITICAL RULES:
               • Do NOT mention "Scientific American", "Sci Am", or "ean" anywhere.
               • Do NOT mention "Lean", "Lean 4", "formal verification", or "proof assistant".
               • This is a premier magazine-quality piece for curious, intelligent readers.
               QUALITY STANDARDS:
               • Superb, vivid, engaging prose with a strong opening hook and narrative arc.
               • Concrete analogies and metaphors that make abstract ideas tangible.
               • Story structure: provocative question → tension → breakthrough → significance.
               • Real-world connections: technology, nature, everyday life.
               • Historical context: place the work in the sweep of intellectual history.
               • 1500–3000 words. Substantial, standalone, enjoyable, interesting.
               • A reader should say "Wow, I had no idea math could do THAT."

            3. **RESEARCH_PAPER.md** — MANDATORY comprehensive, in-depth research paper
               This is a full, publishable-quality paper, NOT a summary:
               • Abstract, Introduction, Definitions & Notation
               • Main Results with detailed proof sketches (not just "by induction")
               • Algorithms with complete pseudocode and complexity analysis
               • Applications with worked examples showing practical use
               • Computational Experiments with tables, charts, numerical results
               • Discussion, Future Work, References
               • 3000–8000 words. Thorough and substantive.

            4. **FUTURE_DIRECTIONS.md** — MANDATORY breakthrough research roadmap
               This is the MOST IMPORTANT deliverable because it drives the next
               research cycle. Structure it as:

               ## Breakthrough Opportunities (ranked by impact)
               For each opportunity:
               - **Theorem Statement**: Precise, formalizable statement with quantifiers
               - **Proof Strategy**: 2-3 concrete approaches with key lemmas identified
               - **Why This Is Revolutionary**: What field it opens, what applications it enables
               - **Catalog Leverage**: Which existing catalog theorems to build on (by name)
               - **Research Mode**: prove | formalize | discover | counterexample
               - **Estimated Depth**: 1-5 scale

               ## Under-explored Territory
               ## Cross-Domain Bridges
               ## Open Problems Encountered

            5. **Python code** — demos, visualizations, algorithms, applications:
               - **demo.py** — concrete numerical examples bringing the math to life
               - **visualizations** — matplotlib/plotly charts (save as PNG/SVG too)
               - **algorithms.py** — implement algorithms from the paper with docstrings
               - **applications.py** — real-world applications (ML, crypto, physics)

            6. **diagram.svg** — visualization of key mathematical structures

            7. **PACKAGE.html** — MANDATORY standalone HTML package
               Bundle ALL artifacts into a single, self-contained HTML file:
               • Everything inlined (CSS, JS, content). No external dependencies.
               • ALL images MUST be embedded as base64 data URIs:
                 `<img src="data:image/png;base64,..." />` for PNGs,
                 `<img src="data:image/svg+xml;base64,..." />` for SVGs.
                 For SVG diagrams, prefer inlining `<svg>...</svg>` markup directly.
                 If you generate matplotlib/plotly charts, convert to base64 and embed.
                 NEVER reference external image files — they won't exist standalone.
               • Tab/sidebar navigation: Article, Research Paper, Demos, Algorithms,
                 Visualizations, Code Listings
               • Modern design: clean typography, dark/light toggle, responsive layout
               • KaTeX for math rendering (CDN OK), syntax-highlighted code blocks
               • Collapsible sections, smooth scroll, table of contents
               • Must work when opened directly in any browser

            Produce novel, non-trivial theorems with complete Lean 4 proofs. Think big — aim for results that would appear in JAMS, Annals, or FOCS.

            ### Catalog Reference Files
            @MachineLearning/OperadicDeepLearning/Foundations.lean
```lean
import Mathlib

/-! # Operadic Deep Learning: Foundations

This file formalizes the algebraic foundations of operadic deep learning theory.
We define symmetric operads, neural layers, and their compositional structure,
then prove foundational theorems connecting neural network composition to operadic
algebraic structure.

## Main Results


### Catalog Reference Files
            @MachineLearning/OperadicDeepLearning/Foundations.lean
```lean
import Mathlib

/-! # Operadic Deep Learning: Foundations

This file formalizes the algebraic foundations of operadic deep learning theory.
We define symmetric operads, neural layers, and their compositional structure,
then prove foundational theorems connecting neural network composition to operadic
algebraic structure.

## Main Results

### Structures and Definitions (7 novel)
* `NeuralOperad` — typeclass capturing operadic structure of neural modules
* `NeuralLayer` — parameterized affine-activation maps with Lipschitz certification
* `OperadicExpression` — tree-structured operadic expressions (free operad elements)
* `DepthSeparationWitness` — certified depth separation between architectures
* `ApproximationCertificate` — operadic approximation with error and Lipschitz bounds
* `OperadicRankBound` — combined rank + Lipschitz robustness certificate
* `operadicLipschitz` — compositional Lipschitz constant computation

### Theorems (35+ proved, zero sorry)
* Neural operad identity, associativity, and Σ₂-equivariance axioms
* Depth separation via generator count and depth-width product
* Lipschitz-certified compositional robustness bounds (L^k for depth k)
* Universal approximation certificates with operadic rate bounds
* Tropical operadic bridge: linear regions and piecewise-linear analysis
* Robustness-expressivity tradeoff theorem
* Parallel vs sequential architecture comparison

## Bridge: connects algebraic topology (operads) → ML (neural networks) →
   analysis (Lipschitz continuity) → cryptography (certified robustness) →
   tropical geometry (piecewise-linear maps) → complexity theory (circuit depth)
-/

noncomputable section

open NNReal

/-! ## I. Core Algebraic Structures -/

/-- `NeuralOperad`: A typeclass capturing the operadic structure of parameterized
    computation modules. Each arity `n` has an associated type of n-input operations,
    with composition satisfying identity and associativity.

    Bridge: connects category theory (operadic composition) to ML (layer stacking). -/
class NeuralOperad (Op : ℕ → Type*) where
  /-- The identity operation -/
  id_op : Op 1
  /-- Operadic composition -/
  compose : {m : ℕ} → Op m → (Fin m → Op 1) → Op m
  /-- Left identity law -/
  compose_id_left : ∀ {m : ℕ} (f : Op m), compose f (fun _ => id_op) = f
  /-- Right identity law -/
  compose_id_right : ∀ (f : Op 1), compose id_op (fun _ => f) = f

/-- `NeuralLayer`: A parameterized affine map ℝⁿ → ℝᵐ composed with activation,
    equipped with a Lipschitz bound for certified robustness.

    Bridge: connects ML (neural layers) to analysis (Lipschitz continuity)
    to cryptography (adversarial robustness certification). -/
structure NeuralLayer (n m : ℕ) where
  /-- Weight matrix entries -/
  weights : Fin m → Fin n → ℝ
  /-- Bias vector -/
  bias : Fin m → ℝ
  /-- Lipschitz constant of the activation function -/
  activationLipschitz : NNReal
  /-- The Lipschitz constant is positive -/
  lipschitz_pos : (0 : NNReal) < activationLipschitz

/-- `OperadicExpression`: A tree-structured expression in the free operad,
    representing a composed neural architecture.

    Bridge: connects algebraic topology (free operads) to ML (architecture design)
    to computational complexity (circuit depth). -/
inductive OperadicExpression where
  | generator : OperadicExpression
  | identity : OperadicExpression
  | compose : OperadicExpression → OperadicExpression → OperadicExpression
  | parallel : OperadicExpression → OperadicExpression → OperadicExpression
  deriving Repr, BEq

namespace OperadicExpression

/-- The depth of an operadic expression: length of the longest sequential chain.
    Parallel composition takes max (branches run concurrently). -/
def depth : OperadicExpression → ℕ
  | generator => 1
  | identity => 0
  | compose e₁ e₂ => e₁.depth + e₂.depth
  | parallel e₁ e₂ => max e₁.depth e₂.depth

/-- The generator count: total number of generator nodes.
    This is the algebraic analog of parameter block count. -/
def generatorCount : OperadicExpression → ℕ
  | generator => 1
  | identity => 0
  | compose e₁ e₂ => e₁.generatorCount + e₂.generatorCount
  | parallel e₁ e₂ => e₁.generatorCount + e₂.generatorCount

/-- Width = generator count (defined separately for conceptual clarity). -/
def width : OperadicExpression → ℕ
  | generator => 1
  | identity => 0
  | compose e₁ e₂ => e₁.width + e₂.width
  | parallel e₁ e₂ => e₁.width + e₂.width

/-- The depth-width product: key combined invariant for approximation rate. -/
def depthWidthProduct (e : OperadicExpression) : ℕ :=
  e.depth * e.generatorCount

end OperadicExpression

/-! ## II. Certified Structures -/

/-- `OperadicRankBound`: Combined rank + Lipschitz robustness certificate.

    Bridge: connects ML model complexity to adversarial robustness
    to post-quantum security (Lipschitz hash functions). -/
structure OperadicRankBound where
  rankBound : ℕ
  lipschitzBound : NNReal
  lipschitz_pos : (0 : NNReal) < lipschitzBound

/-- `DepthSeparationWitness`: Certificate that two architectures at
    different depths have provably different expressivity. -/
structure DepthSeparationWitness (k₁ k₂ : ℕ) where
  shallow : OperadicExpression
  deep : OperadicExpression
  shallow_depth : shallow.depth = k₁
  deep_depth : deep.depth = k₂
  rank_gap : deep.generatorCount > shallow.generatorCount

/-- `ApproximationCertificate`: Operadic approximation with error and Lipschitz bounds. -/
structure ApproximationCertificate where
  expression : OperadicExpression
  errorBound : ℝ
  error_pos : 0 < errorBound
  lipschitzConst : NNReal

/-! ## III. k-Deep Expressions -/

/-- Composing k generators sequentially: the canonical depth-k architecture. -/
def kDeepExpression : ℕ → OperadicExpression
  | 0 => .identity
  | k + 1 => .compose .generator (kDeepExpression k)

/-- A wide parallel arrangement of n generators (depth 1, width n). -/
def wideParallel : ℕ → OperadicExpression
  | 0 => .identity
-- ... (truncated, full file has 631 lines)
```

@AutoResearch/CompactTropicalChoquetRadon.lean
```lean
/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Compact Tropical Choquet–Radon Representation

This file formalizes a Choquet–Radon representation theorem for upper-continuous
max-plus linear functionals on continuous real-valued functions over a compact
Hausdorff space.

## Main definitions

* `UCTropicalFunctional` — A structure encoding an upper-continuous, max-plus linear
  functional on `C(X, ℝ)` with values in `EReal`.
* `compactCapacity` — The compact-set capacity extracted from a functional.
* `infOnCompact` — The infimum of a continuous function on a compact set.
* `tropSupport` — The support of a tropical functional (smallest closed carrier).
* `supportedOn` — Predicate for a functional being supported on a set.
* `pushforwardFunctional` — Pushforward of a tropical functional along a continuous map.

## Main results

* `compactCapacity_empty` — Capacity of the empty compact set is ⊥.
* `compactCapacity_mono` — Capacity is monotone (larger sets, larger capacity).
* `compactCapacity_union` — Capacity is maxitive: `μ(K ∪ L) = max(μ(K), μ(L))`.
* `infOnCompact_le_eval` — The infimum on a compact set is bounded by point evaluation.
* `tropical_choquet_radon_le` — One direction of the representation:
    `⊔_K (μ(K) + inf_K f) ≤ Λ(f)`.
* `isClosed_tropSupport` — The tropical support is closed.
* `tropSupport_supported` — The functional is supported on its tropical support.
* `tropSupport_minimal` — The tropical support is the smallest closed carrier.
* `compactCapacity_pushforward_le` — Capacity is functorial under pushforward.

## Mathematical overview

In max-plus (tropical) algebra, addition is `max` and multiplication is `+`.
A max-plus linear functional Λ on continuous functions satisfies:
- `Λ(f ⊔ g) = Λ(f) ⊔ Λ(g)` (preserves tropical addition = max)
- `Λ(f + c) = Λ(f) + c` (equivariant under tropical scalar action = real translation)

The Choquet–Radon representation expresses such a functional as a "max-plus integral":
  `Λ(f) = ⊔_K (μ(K) + inf_K f)`
where `μ` is a maxitive capacity on compact sets.
-/

noncomputable section

open TopologicalSpace Set EReal

/-! ### The functional structure -/

/-- An upper-continuous tropical (max-plus linear) functional on `C(X, ℝ)`,
taking values in `EReal` (extended reals with ±∞).

The axioms encode:
- `monotone'`: monotonicity with respect to pointwise order
- `sup_preserving'`: max-plus additivity `Λ(f ⊔ g) = max(Λ(f), Λ(g))`
- `shift_equivariant'`: tropical scalar action `Λ(f + c) = Λ(f) + c`
- `normalized'`: normalization `Λ(0) = 0`

The upper-continuity axiom (`top_continuous'`) states that Λ commutes with
directed suprema of continuous functions, provided the supremum is itself continuous.
-/
structure UCTropicalFunctional (X : Type*) [TopologicalSpace X]
    [CompactSpace X] [T2Space X] where
  /-- The underlying function from continuous maps to extended reals. -/
  toFun : C(X, ℝ) → EReal
  /-- The functional is monotone. -/
  monotone' : Monotone toFun
  /-- The functional preserves binary suprema (max-plus additivity). -/
  sup_preserving' : ∀ f g : C(X, ℝ), toFun (f ⊔ g) = toFun f ⊔ toFun g
  /-- The functional is equivariant under translation by real constants. -/
  shift_equivariant' : ∀ (c : ℝ) (f : C(X, ℝ)),
    toFun (f + ContinuousMap.const X c) = toFun f + (c : EReal)
  /-- Upper continuity: Λ commutes with monotone suprema of continuous functions,
      provided the supremum is itself continuous. -/
  top_continuous' : ∀ {ι : Type*} [Nonempty ι] [Preorder ι] (s : ι → C(X, ℝ))
    (f : C(X, ℝ)),
    (∀ x, f x = ⨆ i, (s i x : EReal)) →
    Monotone s →
    toFun f = ⨆ i, toFun (s i)
  /-- Normalization: the zero function maps to zero. -/
  normalized' : toFun 0 = 0

variable {X : Type*} [TopologicalSpace X] [CompactSpace X] [T2Space X]

namespace UCTropicalFunctional

instance : CoeFun (UCTropicalFunctional X) (fun _ => C(X, ℝ) → EReal) :=
  ⟨toFun⟩

@[simp]
theorem coe_toFun (Λ : UCTropicalFunctional X) (f : C(X, ℝ)) :
    Λ f = Λ.toFun f := rfl

theorem monotone (Λ : UCTropicalFunctional X) : Monotone Λ.toFun :=
  Λ.monotone'

theorem sup_preserving (Λ : UCTropicalFunctional X) (f g : C(X, ℝ)) :
    Λ (f ⊔ g) = Λ f ⊔ Λ g :=
  Λ.sup_preserving' f g

theorem shift_equivariant (Λ : UCTropicalFunctional X) (c : ℝ) (f : C(X, ℝ)) :
    Λ (f + ContinuousMap.const X c) = Λ f + (c : EReal) :=
  Λ.shift_equivariant' c f

theorem normalized (Λ : UCTropicalFunctional X) :
    Λ 0 = 0 := Λ.normalized'

/-- The functional maps constant functions to the constant. -/
theorem map_const (Λ : UCTropicalFunctional X) (c : ℝ) :
    Λ (ContinuousMap.const X c) = (c : EReal) := by
  have h := Λ.shift_equivariant c 0
  simp [Λ.normalized] at h
  exact h

/-- As constants decrease to -∞, the functional value goes to ⊥. -/
theorem map_const_neg_iInf (Λ : UCTropicalFunctional X) :
    ⨅ (n : ℕ), Λ (ContinuousMap.const X (-(n : ℝ))) = ⊥ := by
  simp [map_const]
  rw [iInf_eq_bot]
  intro b hb
  induction b with
    | bot => exact absurd rfl (ne_of_gt hb)
    | top => exact ⟨0, by simp⟩
    | coe r =>
      obtain ⟨n, hn⟩ := exists_nat_gt (-r)
      exact ⟨n, EReal.coe_lt_coe_iff.mpr (by linarith)⟩

end UCTropicalFunctional

/-! ### Compact-set capacity -/

/-- The compact-set capacity extracted from a tropical functional.
    `compactCapacity Λ K` is the infimum of `Λ(f)` over all continuous functions `f`
    that are nonneg (≥ 0) on `K`. -/
def compactCapacity (Λ : UCTropicalFunctional X) (K : Compacts X) : EReal :=
  sInf {a : EReal | ∃ f : C(X, ℝ), (∀ x ∈ (K : Set X), (0 : ℝ) ≤ f x) ∧ a = Λ.toFun f}

/-- The infimum of a continuous function over a compact set.
    When `K` is empty, this is `⊤` by convention (infimum of empty set). -/
def infOnCompact (f : C(X, ℝ)) (K : Compacts X) : EReal :=
  ⨅ x ∈ (K : Set X), (f x : EReal)

/-! ### Basic capacity properties -/

/-- Helper: the defining set for compactCapacity is nonempty. -/
-- ... (truncated, full file has 459 lines)
```


### WHAT WE NEED FROM YOU

You are a world-class mathematician, software engineer, and science writer.
Use your judgment on the best way to organize and present your work.
We need ALL of the following deliverables:

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 1 — Formally verified mathematics (Lean 4)
────────────────────────────────────────────────────────────────────────────
- Prove non-trivial theorems with complete proofs (no `sorry` in the final result)
- Organize the code however makes sense — one file or several,
  whatever serves the mathematics best
- Use doc comments to explain the significance of key results

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 2 — Standalone Popular-Science ARTICLE  →  ARTICLE.md
────────────────────────────────────────────────────────────────────────────
Write a **superb, standalone magazine-quality article** about this research.

CRITICAL RULES FOR THE ARTICLE:
• Do NOT mention "Scientific American", "Sci Am", or "ean" anywhere.
• Do NOT mention "Lean", "Lean 4", "formal verification", or "proof assistant".
• This is a POPULAR SCIENCE article for a curious, intelligent audience.
  Write it as if it will be published in a premier science magazine.
• The reader should come away saying "Wow, I had no idea math could do THAT."

ARTICLE QUALITY STANDARDS:
• **Superb writing**: Vivid, engaging prose. Strong opening hook. Narrative arc.
  Use concrete analogies and metaphors that make abstract ideas tangible.
• **Depth without jargon**: Explain the IDEAS, not the formalism.
  A reader with a college education should understand and enjoy every paragraph.
• **Story structure**: Open with a provocative question or surprising fact.
  Build tension. Reveal the breakthrough. Show why it matters.
• **Real-world connections**: Connect to technology, nature, everyday life.
  Why should a non-mathematician care about this?
• **Historical context**: Place the discovery in the sweep of intellectual history.
  Who tried this before? What barriers stood in the way?
• **Length**: 1500–3000 words. Substantial but not padded.
• **Standalone**: The article must make complete sense on its own.
  No references to "the proof above" or "our formal verification."

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 3 — Comprehensive RESEARCH PAPER  →  RESEARCH_PAPER.md
────────────────────────────────────────────────────────────────────────────
Write a **thorough, in-depth research paper** that a mathematician or
graduate student would find valuable. This is NOT a summary — it is a
complete, publishable-quality paper.

RESEARCH PAPER REQUIREMENTS:
• **Abstract**: Concise summary of contributions and significance.
• **Introduction**: Motivation, context, relationship to prior work.
• **Definitions & Notation**: Precise mathematical setup.
• **Main Results**: Full theorem statements with detailed proof sketches.
  Include the key ideas, not just "by induction."
• **Algorithms**: If the work produces algorithms, include complete
  pseudocode with complexity analysis (time, space, convergence).
• **Applications**: Concrete applications with worked examples.
  Show HOW to use the results in practice.
• **Computational Experiments**: Reference the Python demos.
  Include tables, charts, or numerical results.
• **Discussion**: Implications, limitations, open questions.
• **Future Work**: Specific, actionable next steps.
• **References**: Cite relevant prior work properly.
• **Length**: 3000–8000 words. Comprehensive and substantive.

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 4 — Python Code: Demos, Visualizations, Algorithms
────────────────────────────────────────────────────────────────────────────
- **demo.py** — Working Python code demonstrating the theorems with
  concrete numerical examples. Make the math tangible.
- **visualizations** — matplotlib / plotly charts showing key mathematical
  structures, convergence behavior, phase diagrams, etc.
  Save figures as PNG/SVG files for inclusion in the HTML package.
- **algorithms.py** — Implement any algorithms from the research paper.
  Include docstrings, type hints, and example usage.
- **applications.py** — Code showing real-world applications of the results.
  If the math applies to ML, crypto, physics — show it working.

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 5 — FUTURE_DIRECTIONS.md  (MANDATORY — drives next cycle)
────────────────────────────────────────────────────────────────────────────
The MOST IMPORTANT deliverable. Structured roadmap of breakthrough
research opportunities opened by this work. See detailed spec below.

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 6 — Standalone HTML Package  →  PACKAGE.html
────────────────────────────────────────────────────────────────────────────
Create a **single, self-contained HTML file** that bundles ALL artifacts
into a beautiful, interactive presentation. Requirements:

• **Single file**: Everything (CSS, JS, content) inlined. No external deps.
• **Embedded images**: ALL images (charts, diagrams, visualizations) MUST be
  embedded directly in the HTML as base64 data URIs. Use the format:
  `<img src="data:image/png;base64,..." />` for PNGs,
  `<img src="data:image/svg+xml;base64,..." />` for SVGs.
  If you generate matplotlib/plotly figures in Python, convert them to base64
  and embed them. For SVG diagrams, inline the SVG markup directly with
  `<svg>...</svg>` tags — this is preferred over base64 for vector graphics.
  NEVER use `<img src="filename.png">` — the file won't exist when viewing.
• **Navigation**: Sidebar or tab navigation between sections:
  - Article (the popular-science piece)
  - Research Paper (the full paper)
  - Interactive Demos (embedded Python output / JS visualizations)
  - Algorithms (pseudocode + implementation)
  - Visualizations (embedded charts/diagrams as inline SVG or base64)
  - Code Listings (syntax-highlighted Python and proof code)
• **Beautiful design**: Modern, clean typography (system fonts).
  Dark/light mode toggle. Responsive layout. Smooth transitions.
• **Math rendering**: Use KaTeX (CDN link OK for math rendering only)
  for any mathematical notation.
• **Syntax highlighting**: Inline code highlighting for Python blocks.
• **Interactive elements**: Collapsible sections, smooth scroll, TOC.
• The HTML package should work when opened directly in any browser.
• Include ALL content from the article, research paper, and code.

────────────────────────────────────────────────────────────────────────────

The mathematics comes FIRST. Excellent proofs trump everything else.
But great work deserves great presentation — make it real, useful, and
beautiful. Every deliverable should be something you'd be proud to show.

Research domain: Bridges
Research mode: formalize
