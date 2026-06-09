theorem dualRegev_decrypt_eq {n m q : ℕ}
    (sk : DualRegevSK n q) (pk : DualRegevPK n m q)
    (noise : Fin m → ZMod q) (μ : ZMod q) (r : Fin m → ZMod q)
    (hwf : WellFormedKey sk pk noise) :
    dualRegevDec sk (dualRegevEnc pk μ r) =
      μ + ∑ i : Fin m, r i * noise i := by
  -- Expand the definitions of `dualRegevDec` and `dualRegevEnc`.
  unfold dualRegevDec dualRegevEnc;
  -- Substitute the definition of `pk.vecP` from `hwf` into the expression.
  have h_subst : ∑ i, r i * pk.vecP i = ∑ i, r i * (∑ j, pk.matA i j * sk.secret j + noise i) := by
    exact Finset.sum_congr rfl fun i _ => by rw [ hwf i ] ;
  simp_all +decide [ mul_add, Finset.sum_add_distrib, dot', Finset.mul_sum _ _ _, Finset.sum_mul ];
  rw [ Finset.sum_comm ] ; ring;

/-! ## Theorem 3: Zero Noise Implies Exact Decryption

**P**roof: Immediate from `dualRegev_decrypt_eq` with noise = 0.
**E**xample: A noiseless LWE system is just linear algebra over ZMod q.
**G**eneralization: Quantitative version bounds |μ_recovered - μ| by noise norm.
**B**oundary: Noiseless LWE is trivially solvable by Gaussian elimination,
  so this case provides no security.
-/

/-
!-- When all noise terms are zero, ∑ᵢ rᵢ · 0 = 0, so decryption is exact. -- !--
-/

theorem tvdist_triangle {α : Type*} [Fintype α] (μ ν ρ : PMF α) :
    tvdist μ ρ ≤ tvdist μ ν + tvdist ν ρ := by
  unfold tvdist
  rw [← mul_add]
  gcongr
  calc ∑ a : α, |(μ a).toReal - (ρ a).toReal|
      ≤ ∑ a : α, (|(μ a).toReal - (ν a).toReal| + |(ν a).toReal - (ρ a).toReal|) :=
        Finset.sum_le_sum fun a _ => abs_sub_le _ _ _
    _ = _ := Finset.sum_add_distrib

/-! ## Theorem 1: Data-Processing Inequality for TVD

**P**roof: Group preimages by fibers, apply triangle inequality per fiber.
**E**xample: Hashing two close distributions preserves closeness.
**G**eneralization: Extends to randomized maps (Markov kernels).
**B**oundary: The inequality is tight only for injective maps.
-/

/-
!-- By Fubini, ∑_b |f_*μ(b) - f_*ν(b)| = ∑_b |∑_{a:f(a)=b} μ(a) - ν(a)|
≤ ∑_b ∑_{a:f(a)=b} |μ(a) - ν(a)| = ∑_a |μ(a) - ν(a)|. -- !--
-/

theorem hybrid_telescope
    {α : Type*} [Fintype α]
    (n : ℕ) (H : Fin (n + 1) → PMF α) :
    tvdist (H 0) (H (Fin.last n))
      ≤ ∑ i : Fin n, tvdist (H (Fin.castSucc i)) (H i.succ) := by
  -- We proceed by induction on $n$.
  induction' n with n ih;
  · simp +decide [ Fin.last, tvdist_self ];
  · convert le_trans ( tvdist_triangle _ _ _ ) ( add_le_add ( ih fun i => H ( Fin.castSucc i ) ) le_rfl ) using 1;
    rw [ Fin.sum_univ_castSucc ];
    rfl

/-! ## Theorem 3: Hybrid Telescope With Per-Step Bounds

Strengthening: each consecutive pair has its own bound εᵢ.

**P**roof: Combine `hybrid_telescope` with monotonicity of Finset.sum.
**E**xample: In a CPA reduction with different losses at each step.
**G**eneralization: Could use weighted norms instead of ℓ¹ sum.
**B**oundary: ℓ¹ bound is optimal only for worst-case adversaries.
-/

/-
!-- Compose hybrid_telescope with sum monotonicity. -- !--
-/

theorem hybrid_telescope_bounded
    {α : Type*} [Fintype α]
    (n : ℕ) (H : Fin (n + 1) → PMF α)
    (ε : Fin n → ℝ)
    (hstep : ∀ i : Fin n, tvdist (H (Fin.castSucc i)) (H i.succ) ≤ ε i) :
    tvdist (H 0) (H (Fin.last n)) ≤ ∑ i : Fin n, ε i := by
  exact le_trans ( hybrid_telescope n H ) ( Finset.sum_le_sum fun i _ => hstep i )

/-! ## BDD (Bounded Distance Decoding) -/

/-- Euclidean distance in ℤⁿ, cast to ℝ. -/
def euclidDistInt (n : ℕ) (x y : Fin n → ℤ) : ℝ :=
  Real.sqrt (∑ i : Fin n, ((x i - y i : ℤ) : ℝ) ^ 2)

/-- A BDD instance: lattice + target + radius. -/
structure BDDInst where
  n : ℕ
  lattice : Submodule ℤ (Fin n → ℤ)
  target : Fin n → ℤ
  radius : ℝ
  radius_pos : 0 < radius

/-- Well-separation: distinct lattice points are > 2r apart. -/
def BDDInst.wellSep (I : BDDInst) : Prop :=
  ∀ x y : Fin I.n → ℤ, x ∈ I.lattice → y ∈ I.lattice →
    x ≠ y → euclidDistInt I.n x y > 2 * I.radius

/-! ## Theorem 4: Euclidean Distance Triangle Inequality -/

/-
!-- Use the EuclideanSpace norm triangle inequality from Mathlib,
then convert back to our definition. -- !--
-/

theorem reduction_chain_bound {α : Type*} [Fintype α]
    (chain : ReductionChain α) :
    tvdist (chain.games 0) (chain.games (Fin.last chain.numSteps))
      ≤ ∑ i : Fin chain.numSteps, chain.losses i := by
  convert hybrid_telescope_bounded chain.numSteps chain.games chain.losses chain.step_bound

end