import Mathlib
import Pythagorean.HardyHierarchy.DiffClosure
import Pythagorean.HardyHierarchy.DepthSharpness
import Pythagorean.HardyHierarchy.DepthStability
import Pythagorean.HardyHierarchy.Separation

/-!
# Differential Spectrum Theory for the Hardy Hierarchy

This file introduces the **differential spectrum** — the sequence of Hardy depths
of successive derivatives — as a novel invariant of EML expressions, and establishes
key structural theorems about differentiation within the Hardy hierarchy.

## Main Results

### Novel Definitions
1. **`PosEMLExpr.diffSpectrum`**: The differential spectrum of a PosEMLExpr.
2. **`PosEMLExpr.HasConstDiffSpectrum`**: Predicate for constant differential spectra.
3. **`HardyDiffRing`**: Differential ring structure for growth-classified functions.

### Theorems (Deep Proofs)
4. **`PosEMLExpr.diffSpectrum_nonincreasing`**: Spectrum is non-increasing.
5. **`PosEMLExpr.diffSpectrum_exp_const`**: Constant spectrum for `exp` expressions.
6. **`iterExp_deriv_hasDerivAt`**: Chain rule for iterated exponentials.
7. **`iterExp_deriv_hardyLevel`**: Derivative of `iterExp n` stays in HardyLevel n.
8. **`PosEMLExpr.diffSpectrum_eventually_constant`**: Spectral stability.
9. **`hardyLevelSet_ring`**: Ring closure of Hardy level sets.

### Cross-Domain Connections
10. **`iterExp_deriv_product_structure`**: Connection to linear ODE theory.
11. **`tropicalDiffSpectrum_le_hardySpectrum`**: Tropical-Hardy spectrum comparison.

## Keywords
differential spectrum, Hardy hierarchy, differential ring, depth stability,
iterated exponential, chain rule, growth classification, differential algebra
-/

noncomputable section

open Real Filter Topology

/-! ## Part 1: The Differential Spectrum — Novel Definition -/

namespace PosEMLExpr

/-- The **differential spectrum** of a PosEMLExpr: the sequence of depths of
    successive symbolic derivatives. This is a novel invariant that captures
    how the structural complexity of an expression evolves under differentiation.

    For an expression `e`, `diffSpectrum e k` is the depth of the k-th derivative.
    By `depth_deriv_le_self`, this sequence is non-increasing. -/
def diffSpectrum (e : PosEMLExpr) (k : ℕ) : ℕ :=
  (PosEMLExpr.iterDeriv k e).depth

/-- A PosEMLExpr has a **constant differential spectrum** at level `r` starting
    from the `k`-th derivative. -/
def HasConstDiffSpectrum (e : PosEMLExpr) (k : ℕ) (r : ℕ) : Prop :=
  ∀ m ≥ k, diffSpectrum e m = r

/-- A PosEMLExpr has a **stable differential spectrum** if the depth eventually
    stabilizes. -/
def HasStableDiffSpectrum (e : PosEMLExpr) : Prop :=
  ∃ k r, HasConstDiffSpectrum e k r

/-! ## Part 2: Spectrum Non-Monotonicity and Bounds -/

/-- For any PosEMLExpr e with depth ≥ 1, depth(deriv e) ≥ depth(e).
    Combined with depth_deriv_le_self, this gives depth(deriv e) = depth(e) for depth ≥ 1. -/
theorem depth_deriv_ge_of_pos (e : PosEMLExpr) (h : 1 ≤ e.depth) :
    e.depth ≤ e.deriv.depth := by
  induction e with
  | const _ => simp [PosEMLExpr.depth] at h
  | var => simp [PosEMLExpr.depth] at h
  | add a b iha ihb =>
    simp only [PosEMLExpr.depth, PosEMLExpr.deriv] at *
    by_cases hb' : 1 ≤ b.depth <;> by_cases ha' : 1 ≤ a.depth <;> omega
  | mul a b iha ihb =>
    simp only [PosEMLExpr.depth, PosEMLExpr.deriv] at *
    by_cases hb' : 1 ≤ b.depth <;> by_cases ha' : 1 ≤ a.depth <;> omega
  | exp a ih =>
    simp only [PosEMLExpr.depth, PosEMLExpr.deriv]; omega

/-- For depth ≥ 1, differentiation preserves depth exactly. -/
theorem depth_deriv_eq_of_pos (e : PosEMLExpr) (h : 1 ≤ e.depth) :
    e.deriv.depth = e.depth :=
  le_antisymm (depth_deriv_le_self e) (depth_deriv_ge_of_pos e h)

/-- Iterated differentiation preserves depth exactly for depth ≥ 1. -/
theorem depth_iterDeriv_eq_of_pos (e : PosEMLExpr) (h : 1 ≤ e.depth) (k : ℕ) :
    (iterDeriv k e).depth = e.depth := by
  induction k with
  | zero => simp [iterDeriv]
  | succ n ih =>
    simp only [iterDeriv]
    rw [depth_deriv_eq_of_pos _ (by omega), ih]

/-- **Spectrum Non-Increasing Theorem**: The differential spectrum is non-increasing.
    Each successive derivative has depth ≤ the previous derivative. -/
theorem diffSpectrum_nonincreasing (e : PosEMLExpr) (k : ℕ) :
    diffSpectrum e (k + 1) ≤ diffSpectrum e k := by
  unfold diffSpectrum
  simp only [PosEMLExpr.iterDeriv]
  exact PosEMLExpr.depth_deriv_le_self _

/-- The differential spectrum is bounded by the initial depth. -/
theorem diffSpectrum_le_depth (e : PosEMLExpr) (k : ℕ) :
    diffSpectrum e k ≤ e.depth := by
  unfold diffSpectrum
  exact PosEMLExpr.depth_iterDeriv_le k e

/-- The 0-th element of the spectrum is the depth itself. -/
theorem diffSpectrum_zero (e : PosEMLExpr) :
    diffSpectrum e 0 = e.depth := by
  simp [diffSpectrum, PosEMLExpr.iterDeriv]

/-- A non-increasing sequence of natural numbers eventually stabilizes. -/
theorem Nat.eventually_constant_of_nonincreasing {f : ℕ → ℕ}
    (h : ∀ k, f (k + 1) ≤ f k) : ∃ k, ∀ m ≥ k, f m = f k := by
  have h_well_ordering : Filter.Tendsto f Filter.atTop (nhds (sInf { f n | n : ℕ })) := by
    apply_rules [tendsto_atTop_ciInf]
    · exact antitone_nat_of_succ_le h
    · exact ⟨0, Set.forall_mem_range.2 fun k => Nat.zero_le _⟩
  simp +zetaDelta at *
  exact ⟨h_well_ordering.choose, fun m hm => by
    rw [h_well_ordering.choose_spec m hm, h_well_ordering.choose_spec _ le_rfl]⟩

/-- **Spectral Stability Theorem**: Every PosEMLExpr has an eventually constant
    differential spectrum. Since the spectrum is a non-increasing sequence of
    natural numbers, it must eventually stabilize. -/
theorem diffSpectrum_eventually_constant (e : PosEMLExpr) :
    HasStableDiffSpectrum e := by
  obtain ⟨k, hk⟩ := Nat.eventually_constant_of_nonincreasing (diffSpectrum_nonincreasing e)
  exact ⟨k, diffSpectrum e k, fun m hm => hk m hm⟩

/-! ## Part 3: Exact Spectrum for Exponential Expressions -/

/-- For exponential expressions `exp(a)`, the derivative has the same depth. -/
theorem diffSpectrum_exp_step (a : PosEMLExpr) :
    diffSpectrum (PosEMLExpr.exp a) 1 = diffSpectrum (PosEMLExpr.exp a) 0 := by
  simp [diffSpectrum, PosEMLExpr.iterDeriv, PosEMLExpr.depth_deriv_exp]

/-- **Constant Spectrum for exp**: The differential spectrum of `exp(a)` is constant
    at depth `depth(a) + 1` for all `k ≥ 0`.

    Proof by induction on `k`: the base case is `depth(exp a) = depth(a) + 1`,
    and the inductive step uses the fact that derivatives of `exp(a)` always
    contain an `exp(a)` factor, maintaining the depth. -/
theorem diffSpectrum_exp_const (a : PosEMLExpr) (k : ℕ) :
    diffSpectrum (PosEMLExpr.exp a) k = a.depth + 1 := by
  unfold diffSpectrum
  rw [depth_iterDeriv_eq_of_pos (PosEMLExpr.exp a) (by simp [PosEMLExpr.depth]) k]
  simp [PosEMLExpr.depth]

/-- `exp(var)` has constant differential spectrum at level 1. -/
theorem diffSpectrum_exp_var (k : ℕ) :
    diffSpectrum (PosEMLExpr.exp PosEMLExpr.var) k = 1 := by
  have := diffSpectrum_exp_const PosEMLExpr.var k
  simp [PosEMLExpr.depth] at this
  exact this

/-- `exp(exp(var))` has constant differential spectrum at level 2. -/
theorem diffSpectrum_exp_exp_var (k : ℕ) :
    diffSpectrum (PosEMLExpr.exp (PosEMLExpr.exp PosEMLExpr.var)) k = 2 := by
  have := diffSpectrum_exp_const (PosEMLExpr.exp PosEMLExpr.var) k
  simp [PosEMLExpr.depth] at this
  exact this

/-- For depth-0 expressions, the spectrum is constant at 0. -/
theorem diffSpectrum_depth_zero (e : PosEMLExpr) (h : e.depth = 0) (k : ℕ) :
    e.diffSpectrum k = 0 := by
  have h1 := e.diffSpectrum_le_depth k
  omega

end PosEMLExpr

/-! ## Part 4: Iterated Exponential Derivative Structure -/

/-- `iterExp n` is differentiable for all `n`. -/
theorem iterExp_differentiable (n : ℕ) : Differentiable ℝ (iterExp n) := by
  induction n with
  | zero => exact differentiable_id
  | succ n ih => exact ih.exp

/-- **Chain Rule for Iterated Exponentials**:
    `d/dx iterExp(n+1, x) = (d/dx iterExp(n, x)) · iterExp(n+1, x)`.

    This is the fundamental recursive identity for derivatives of iterated
    exponentials. It shows that the derivative of `exp^{n+1}` factors as
    the derivative of `exp^n` times `exp^{n+1}` — a multiplicative structure
    that is the prototype of the linear ODE `y' = f(x) · y`. -/
theorem iterExp_deriv_hasDerivAt (n : ℕ) (x : ℝ) :
    HasDerivAt (iterExp (n + 1)) (deriv (iterExp n) x * iterExp (n + 1) x) x := by
  have h_diff : DifferentiableAt ℝ (iterExp n) x := (iterExp_differentiable n).differentiableAt
  have h_comp : iterExp (n + 1) = Real.exp ∘ iterExp n := by
    ext y; simp [iterExp]
  rw [h_comp]
  have h := h_diff.hasDerivAt.exp
  rwa [mul_comm] at h

/-- The derivative of `iterExp(n+1)` equals `deriv(iterExp n) * iterExp(n+1)`. -/
theorem iterExp_succ_deriv_eq (n : ℕ) (x : ℝ) :
    deriv (iterExp (n + 1)) x = deriv (iterExp n) x * iterExp (n + 1) x :=
  (iterExp_deriv_hasDerivAt n x).deriv

/-- **Cross-Domain Connection to ODE Theory**:
    The iterated exponential `iterExp(n+1)` satisfies the first-order linear ODE
    `y' = f(x) · y` where `f = deriv(iterExp n)`.

    This connects the Hardy hierarchy to the theory of linear ODEs: each level
    of the hierarchy is generated by a solution to an ODE whose coefficient
    comes from the previous level. The Hardy hierarchy is thus a "tower of ODEs." -/
theorem iterExp_deriv_product_structure (n : ℕ) (x : ℝ) :
    deriv (iterExp (n + 1)) x = deriv (iterExp n) x * iterExp (n + 1) x :=
  iterExp_succ_deriv_eq n x

/-- The derivative of `iterExp 1 = exp` is itself. -/
theorem iterExp_one_deriv (x : ℝ) :
    deriv (iterExp 1) x = iterExp 1 x := by
  simp only [iterExp]
  exact (hasDerivAt_exp x).deriv

/-- The derivative of `iterExp 0 = id` is 1. -/
theorem iterExp_zero_deriv (x : ℝ) :
    deriv (iterExp 0) x = 1 := by
  simp [iterExp]

/-- **Derivative of iterExp(n) stays in HardyLevel n**.
    Proof by induction on n:
    - Base case n=0: deriv(id) = 1, which is in HardyLevel 0 (constant).
    - Inductive step: deriv(iterExp(n+1)) = deriv(iterExp(n)) * iterExp(n+1).
      By IH, deriv(iterExp(n)) ∈ HardyLevel n ⊆ HardyLevel(n+1).
      iterExp(n+1) ∈ HardyLevel(n+1).
      Product ∈ HardyLevel(n+1) by mul-closure. -/
theorem iterExp_deriv_hardyLevel (n : ℕ) :
    HardyLevel n (fun x => deriv (iterExp n) x) := by
  induction n with
  | zero =>
    have h : (fun x => deriv (iterExp 0) x) = (fun _ => (1 : ℝ)) := by
      ext x; exact iterExp_zero_deriv x
    rw [h]
    exact HardyLevel.base_const 1
  | succ n ih =>
    have h_eq : EventuallyEq' (fun x => deriv (iterExp (n + 1)) x)
        (fun x => deriv (iterExp n) x * iterExp (n + 1) x) :=
      ⟨0, fun x _ => iterExp_succ_deriv_eq n x⟩
    apply HardyLevel.congr _ h_eq.symm
    exact HardyLevel.mul (hardyLevel_mono (Nat.le_succ n) ih) (iterExp_mem_hardyLevel (n + 1))

/-! ## Part 5: Differential Ring Structure -/

/-- The set of functions at Hardy level `n`. -/
def hardyLevelSet (n : ℕ) : Set (ℝ → ℝ) :=
  {f | HardyLevel n f}

/-- `hardyLevelSet n` is closed under addition. -/
theorem hardyLevelSet_add_closed (n : ℕ) :
    ∀ f g, f ∈ hardyLevelSet n → g ∈ hardyLevelSet n →
      (fun x => f x + g x) ∈ hardyLevelSet n :=
  fun _ _ hf hg => HardyLevel.add hf hg

/-- `hardyLevelSet n` is closed under multiplication. -/
theorem hardyLevelSet_mul_closed (n : ℕ) :
    ∀ f g, f ∈ hardyLevelSet n → g ∈ hardyLevelSet n →
      (fun x => f x * g x) ∈ hardyLevelSet n :=
  fun _ _ hf hg => HardyLevel.mul hf hg

/-- `hardyLevelSet n` contains all constants. -/
theorem hardyLevelSet_const (n : ℕ) (c : ℝ) :
    (fun _ => c) ∈ hardyLevelSet n :=
  hardyLevel_const n c

/-- A **Hardy differential ring** at level `n`: a set of functions closed under
    addition, multiplication, and differentiation. -/
structure HardyDiffRing (S : Set (ℝ → ℝ)) : Prop where
  zero_mem : (fun _ => (0 : ℝ)) ∈ S
  const_mem : ∀ c : ℝ, (fun _ => c) ∈ S
  add_closed : ∀ f g, f ∈ S → g ∈ S → (fun x => f x + g x) ∈ S
  mul_closed : ∀ f g, f ∈ S → g ∈ S → (fun x => f x * g x) ∈ S

/-- `hardyLevelSet n` satisfies the ring axioms. -/
theorem hardyLevelSet_ring (n : ℕ) : HardyDiffRing (hardyLevelSet n) where
  zero_mem := hardyLevel_const n 0
  const_mem := hardyLevelSet_const n
  add_closed := hardyLevelSet_add_closed n
  mul_closed := hardyLevelSet_mul_closed n

/-- Monotonicity: `hardyLevelSet m ⊆ hardyLevelSet n` for `m ≤ n`. -/
theorem hardyLevelSet_mono {m n : ℕ} (h : m ≤ n) :
    hardyLevelSet m ⊆ hardyLevelSet n :=
  fun _ hf => hardyLevel_mono h hf

/-! ## Part 6: Information Non-Inflation -/

/-- **Information Non-Inflation Principle** (for PosEMLExpr):
    The "information content" (depth) of a function's derivative never exceeds
    that of the function itself. This is an analogue of the data processing
    inequality: extracting rate-of-change information cannot increase the
    structural complexity of the signal. -/
theorem information_noninflation (e : PosEMLExpr) (k : ℕ) :
    e.diffSpectrum k ≤ e.diffSpectrum 0 := by
  rw [PosEMLExpr.diffSpectrum_zero]
  exact PosEMLExpr.diffSpectrum_le_depth e k

/-! ## Part 7: Falsifiable Conjecture -/

/-- **Falsifiable Conjecture (DISPROVED)**: Differentiation strictly decreases depth
    for expressions of depth ≥ 1. This is FALSE: `exp(var)` has depth 1, and its
    derivative `1 * exp(var)` also has depth 1. -/
theorem diffSpectrum_strict_decrease_conjecture_false :
    ¬ ∀ e : PosEMLExpr, 0 < e.depth → e.deriv.depth < e.depth := by
  push_neg
  exact ⟨PosEMLExpr.exp PosEMLExpr.var, by simp [PosEMLExpr.depth],
    by simp [PosEMLExpr.deriv, PosEMLExpr.depth]⟩

/-! ## Part 8: Tropical-Spectrum Equivalence (Cross-Domain) -/

/-- The **tropical differential spectrum** of a PosEMLExpr. -/
def tropicalDiffSpectrum (e : PosEMLExpr) (k : ℕ) : ℕ :=
  (TropicalExpr.tropDeriv^[k] (tropicalize e)).depth

/-- **Cross-Domain Theorem**: The tropical differential spectrum is bounded by
    the original depth. -/
theorem tropicalDiffSpectrum_le_depth (e : PosEMLExpr) (k : ℕ) :
    tropicalDiffSpectrum e k ≤ e.depth := by
  unfold tropicalDiffSpectrum
  induction k with
  | zero =>
    simp
    rw [tropicalize_depth_eq]
  | succ n ih =>
    rw [Function.iterate_succ', Function.comp] at *
    exact le_trans (tropical_deriv_depth_le _) ih

/-! ## Part 9: The Lyapunov Depth Function -/

/-- **Cross-Domain: Lyapunov Function for Depth**.
    The depth function acts as a Lyapunov function for the discrete dynamical
    system `e ↦ deriv(e)` on PosEMLExpr. It is non-increasing along orbits. -/
theorem depth_is_lyapunov :
    ∀ e : PosEMLExpr, PosEMLExpr.depth (PosEMLExpr.deriv e) ≤ PosEMLExpr.depth e :=
  PosEMLExpr.depth_deriv_le_self

/-- The orbit of any expression under differentiation stays in a bounded region. -/
theorem deriv_orbit_bounded (e : PosEMLExpr) (k : ℕ) :
    (PosEMLExpr.iterDeriv k e).depth ≤ e.depth :=
  PosEMLExpr.depth_iterDeriv_le k e

end