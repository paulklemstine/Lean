import NumberTheory.RLHFGibbsVariational

/-!
# Euler products from RLHF: the zeta policy on smooth-number response spaces

We instantiate the Gibbs variational principle of `NumberTheory.RLHFGibbsVariational`
with an arithmetic reward model.  The response space is the set of `{p, q}`-smooth
integers `p^a q^b` with bounded exponents, the SFT reference is uniform, and the reward is
the logarithmic (Dirichlet) reward `r(n) = -β s log n`.

The optimal (Gibbs) policy is then the **truncated zeta distribution** `π(n) ∝ n^{-s}`, and
the number-theoretic Euler product manifests itself as a *statistical independence* of the
prime exponents under the aligned policy, together with an *additive* decomposition of the
RLHF free energy over primes.

Main results:

* `RLHF.zeta_partition_factorizes` — Euler factorization of the normalizing constant.
* `RLHF.gibbs_zeta_policy` — the optimal RLHF policy is exactly `n^{-s} / ∑ n^{-s}`.
* `RLHF.gibbs_zeta_independent` — under the optimal policy the prime exponents are
  independent (the policy is a product of two truncated geometric laws).
* `RLHF.freeEnergy_euler_additive` — the RLHF free energy splits additively over the primes.
* `RLHF.smoothVal_injective` — unique factorization: the response space really is a set of
  distinct integers.
* `RLHF.euler_factor_tsum` — removing the exponent cutoff, the local partition function is
  the classical Euler factor `(1 - p^{-s})⁻¹`.
-/

namespace RLHF

open Finset

/-! ## 1. Uniform reference policies -/

/-- The uniform distribution on a nonempty finite type. -/
noncomputable def uniformDist (Ω : Type*) [Fintype Ω] : Ω → ℝ :=
  fun _ => 1 / (Fintype.card Ω : ℝ)

theorem uniformDist_isPosDist (Ω : Type*) [Fintype Ω] [Nonempty Ω] :
    IsPosDist (uniformDist Ω) := by
  have hcard : (0 : ℝ) < (Fintype.card Ω : ℝ) := by
    exact_mod_cast Fintype.card_pos
  refine ⟨fun _ => by unfold uniformDist; positivity, ?_⟩
  unfold uniformDist
  rw [Finset.sum_const, Finset.card_univ, nsmul_eq_mul]
  field_simp

/-! ## 2. The smooth-number response space -/

variable {A B : ℕ}

/-- The response space: pairs of bounded prime exponents. -/
abbrev Smooth (A B : ℕ) := Fin (A + 1) × Fin (B + 1)

/-- The integer named by a pair of exponents. -/
def smoothVal (p q : ℕ) (ab : Smooth A B) : ℕ := p ^ (ab.1 : ℕ) * q ^ (ab.2 : ℕ)

theorem smoothVal_pos {p q : ℕ} (hp : 0 < p) (hq : 0 < q) (ab : Smooth A B) :
    0 < smoothVal p q ab := by
  unfold smoothVal; positivity

/-- **Unique factorization.**  For distinct primes the exponent-naming map is injective, so
the response space is a genuine set of `(A,B)`-bounded `{p,q}`-smooth integers. -/
theorem smoothVal_injective {p q : ℕ} (hp : p.Prime) (hq : q.Prime) (hpq : p ≠ q) :
    Function.Injective (smoothVal (A := A) (B := B) p q) := by
  rintro ⟨a, b⟩ ⟨c, d⟩ h
  simp only [smoothVal] at h
  have hpne : p ^ (a : ℕ) ≠ 0 := pow_ne_zero _ hp.pos.ne'
  have hqne : q ^ (b : ℕ) ≠ 0 := pow_ne_zero _ hq.pos.ne'
  have hpne' : p ^ (c : ℕ) ≠ 0 := pow_ne_zero _ hp.pos.ne'
  have hqne' : q ^ (d : ℕ) ≠ 0 := pow_ne_zero _ hq.pos.ne'
  have hfp := congrArg (fun n : ℕ => n.factorization p) h
  have hfq := congrArg (fun n : ℕ => n.factorization q) h
  simp only [Nat.factorization_mul hpne hqne, Nat.factorization_mul hpne' hqne',
    hp.factorization_pow, hq.factorization_pow, Finsupp.coe_add, Pi.add_apply,
    Finsupp.single_apply, if_neg hpq, if_neg (Ne.symm hpq)] at hfp hfq
  have ha : (a : ℕ) = (c : ℕ) := by simpa using hfp
  have hb : (b : ℕ) = (d : ℕ) := by simpa using hfq
  exact Prod.ext (Fin.ext ha) (Fin.ext hb)

/-! ## 3. The Dirichlet (log) reward and the truncated zeta weights -/

/-- The Dirichlet reward model: `r(n) = -β s log n`.  Maximizing reward means preferring
*small* integers, with `s` the sharpness of the preference. -/
noncomputable def zetaReward (β s : ℝ) (p q : ℕ) : Smooth A B → ℝ :=
  fun ab => -(β * s) * Real.log (smoothVal p q ab : ℝ)

/-- The truncated zeta weight `n ↦ n^{-s}`. -/
noncomputable def zetaWeight (s : ℝ) (n : ℕ) : ℝ := (n : ℝ) ^ (-s)

/-- The truncated zeta normalizing constant over the smooth response space. -/
noncomputable def zetaSum (s : ℝ) (p q : ℕ) (A B : ℕ) : ℝ :=
  ∑ ab : Smooth A B, zetaWeight s (smoothVal p q ab)

/-- The local (single prime) partition function with exponents bounded by `A`. -/
noncomputable def localZeta (s : ℝ) (p : ℕ) (A : ℕ) : ℝ :=
  ∑ a : Fin (A + 1), zetaWeight s (p ^ (a : ℕ))

theorem zetaWeight_pos {s : ℝ} {n : ℕ} (hn : 0 < n) : 0 < zetaWeight s n := by
  have : (0 : ℝ) < (n : ℝ) := by exact_mod_cast hn
  unfold zetaWeight
  positivity

theorem localZeta_pos {s : ℝ} {p A : ℕ} (hp : 0 < p) : 0 < localZeta s p A := by
  apply Finset.sum_pos
  · intro a _; exact zetaWeight_pos (pow_pos hp _)
  · exact univ_nonempty

theorem zetaSum_pos {s : ℝ} {p q : ℕ} (hp : 0 < p) (hq : 0 < q) : 0 < zetaSum s p q A B := by
  apply Finset.sum_pos
  · intro ab _; exact zetaWeight_pos (smoothVal_pos hp hq ab)
  · exact univ_nonempty

/-- Complete multiplicativity of the zeta weights. -/
theorem zetaWeight_mul {s : ℝ} {m n : ℕ} (hm : 0 < m) (hn : 0 < n) :
    zetaWeight s (m * n) = zetaWeight s m * zetaWeight s n := by
  have hm' : (0 : ℝ) ≤ (m : ℝ) := by positivity
  have hn' : (0 : ℝ) ≤ (n : ℝ) := by positivity
  unfold zetaWeight
  rw [Nat.cast_mul, Real.mul_rpow hm' hn']

/-- **Euler factorization of the partition function.** -/
theorem zeta_partition_factorizes {s : ℝ} {p q : ℕ} (hp : 0 < p) (hq : 0 < q) :
    zetaSum s p q A B = localZeta s p A * localZeta s q B := by
  unfold zetaSum localZeta
  rw [Fintype.sum_prod_type, Finset.sum_mul_sum]
  refine Finset.sum_congr rfl (fun a _ => Finset.sum_congr rfl (fun b _ => ?_))
  exact zetaWeight_mul (pow_pos hp _) (pow_pos hq _)

/-! ## 4. The optimal RLHF policy is the truncated zeta distribution -/

theorem exp_zetaReward {β s : ℝ} {p q : ℕ} (hβ : 0 < β) (hp : 0 < p) (hq : 0 < q)
    (ab : Smooth A B) :
    Real.exp (zetaReward β s p q ab / β) = zetaWeight s (smoothVal p q ab) := by
  have hn : (0 : ℝ) < (smoothVal p q ab : ℝ) := by
    exact_mod_cast smoothVal_pos hp hq ab
  unfold zetaReward zetaWeight
  rw [Real.rpow_def_of_pos hn]
  congr 1
  field_simp

/-- The partition function of the RLHF problem with uniform reference and Dirichlet reward
is the truncated zeta sum, up to the uniform normalization. -/
theorem partition_zetaReward {β s : ℝ} {p q : ℕ} (hβ : 0 < β) (hp : 0 < p) (hq : 0 < q) :
    partition β (zetaReward (A := A) (B := B) β s p q) (uniformDist (Smooth A B))
      = zetaSum s p q A B / (Fintype.card (Smooth A B) : ℝ) := by
  unfold partition zetaSum uniformDist
  rw [Finset.sum_div]
  refine Finset.sum_congr rfl (fun ab _ => ?_)
  rw [exp_zetaReward hβ hp hq]
  ring

/-- **The aligned policy is the zeta distribution.**  The unique maximizer of the
KL-regularized RLHF objective with the Dirichlet reward and uniform SFT reference is
`π(n) = n^{-s} / ∑ n^{-s}`. -/
theorem gibbs_zeta_policy {β s : ℝ} {p q : ℕ} (hβ : 0 < β) (hp : 0 < p) (hq : 0 < q)
    (ab : Smooth A B) :
    gibbsPolicy β (zetaReward β s p q) (uniformDist (Smooth A B)) ab
      = zetaWeight s (smoothVal p q ab) / zetaSum s p q A B := by
  have hcard : (0 : ℝ) < (Fintype.card (Smooth A B) : ℝ) := by
    exact_mod_cast Fintype.card_pos
  have hZ : (0 : ℝ) < zetaSum s p q A B := zetaSum_pos (A := A) (B := B) hp hq
  unfold gibbsPolicy
  rw [partition_zetaReward hβ hp hq, exp_zetaReward hβ hp hq]
  unfold uniformDist
  field_simp

/-- **Independence of prime exponents under the aligned policy.**  The optimal RLHF policy
factorizes as a product of two truncated geometric laws, one per prime — a probabilistic
avatar of the Euler product. -/
theorem gibbs_zeta_independent {β s : ℝ} {p q : ℕ} (hβ : 0 < β) (hp : 0 < p) (hq : 0 < q)
    (ab : Smooth A B) :
    gibbsPolicy β (zetaReward β s p q) (uniformDist (Smooth A B)) ab
      = (zetaWeight s (p ^ (ab.1 : ℕ)) / localZeta s p A)
        * (zetaWeight s (q ^ (ab.2 : ℕ)) / localZeta s q B) := by
  have h1 : (0 : ℝ) < localZeta s p A := localZeta_pos hp
  have h2 : (0 : ℝ) < localZeta s q B := localZeta_pos hq
  rw [gibbs_zeta_policy hβ hp hq, zeta_partition_factorizes (A := A) (B := B) hp hq]
  unfold smoothVal
  rw [zetaWeight_mul (pow_pos hp _) (pow_pos hq _)]
  field_simp

/-! ## 5. Additivity of the free energy over primes -/

/-- **Euler-additivity of the RLHF free energy.**  The optimal value of the KL-regularized
RLHF objective decomposes as a sum of local (per-prime) contributions minus the entropy
term of the uniform reference. -/
theorem freeEnergy_euler_additive {β s : ℝ} {p q : ℕ} (hβ : 0 < β) (hp : 0 < p) (hq : 0 < q) :
    β * Real.log (partition β (zetaReward (A := A) (B := B) β s p q)
        (uniformDist (Smooth A B)))
      = β * (Real.log (localZeta s p A) + Real.log (localZeta s q B)
          - Real.log (Fintype.card (Smooth A B) : ℝ)) := by
  have hcard : (0 : ℝ) < (Fintype.card (Smooth A B) : ℝ) := by
    exact_mod_cast Fintype.card_pos
  have h1 : (0 : ℝ) < localZeta s p A := localZeta_pos hp
  have h2 : (0 : ℝ) < localZeta s q B := localZeta_pos hq
  rw [partition_zetaReward hβ hp hq, zeta_partition_factorizes (A := A) (B := B) hp hq,
    Real.log_div (by positivity) (ne_of_gt hcard), Real.log_mul (ne_of_gt h1) (ne_of_gt h2)]

/-- The optimal RLHF value with the Dirichlet reward, in Euler-product form. -/
theorem objective_gibbs_euler {β s : ℝ} {p q : ℕ} [Nonempty (Smooth A B)]
    (hβ : 0 < β) (hp : 0 < p) (hq : 0 < q) :
    objective β (zetaReward (A := A) (B := B) β s p q) (uniformDist (Smooth A B))
        (gibbsPolicy β (zetaReward β s p q) (uniformDist (Smooth A B)))
      = β * (Real.log (localZeta s p A) + Real.log (localZeta s q B)
          - Real.log (Fintype.card (Smooth A B) : ℝ)) := by
  rw [objective_gibbs hβ (uniformDist_isPosDist (Smooth A B))]
  exact freeEnergy_euler_additive hβ hp hq

/-! ## 6. Closed forms and the classical Euler factor -/

theorem zetaWeight_pow {s : ℝ} {p : ℕ} (hp : 0 < p) (a : ℕ) :
    zetaWeight s (p ^ a) = (zetaWeight s p) ^ a := by
  have hx : (0 : ℝ) < (p : ℝ) := by exact_mod_cast hp
  unfold zetaWeight
  rw [Nat.cast_pow, ← Real.rpow_natCast (p : ℝ) a, ← Real.rpow_natCast ((p : ℝ) ^ (-s)) a,
    ← Real.rpow_mul hx.le, ← Real.rpow_mul hx.le]
  ring_nf

/-- Closed (geometric) form of the local partition function. -/
theorem localZeta_geom {s : ℝ} {p A : ℕ} (hp : 0 < p) (hne : zetaWeight s p ≠ 1) :
    localZeta s p A = ((zetaWeight s p) ^ (A + 1) - 1) / (zetaWeight s p - 1) := by
  unfold localZeta
  rw [show (∑ a : Fin (A + 1), zetaWeight s (p ^ (a : ℕ)))
      = ∑ a ∈ Finset.range (A + 1), zetaWeight s (p ^ a) by
    rw [Finset.sum_range fun a => zetaWeight s (p ^ a)]]
  rw [Finset.sum_congr rfl (fun a _ => zetaWeight_pow hp a)]
  exact geom_sum_eq hne (A + 1)

theorem zetaWeight_lt_one {s : ℝ} {p : ℕ} (hp : 2 ≤ p) (hs : 0 < s) : zetaWeight s p < 1 := by
  have hx : (1 : ℝ) < (p : ℝ) := by exact_mod_cast hp
  unfold zetaWeight
  exact Real.rpow_lt_one_of_one_lt_of_neg hx (neg_neg_iff_pos.mpr hs)

/-- **The classical Euler factor.**  Removing the exponent cutoff, the local partition
function of the aligned policy sums to `(1 - p^{-s})⁻¹`. -/
theorem euler_factor_tsum {s : ℝ} {p : ℕ} (hp : 2 ≤ p) (hs : 0 < s) :
    ∑' a : ℕ, zetaWeight s (p ^ a) = (1 - zetaWeight s p)⁻¹ := by
  have hp0 : 0 < p := by omega
  have hlt : zetaWeight s p < 1 := zetaWeight_lt_one hp hs
  have hnn : 0 ≤ zetaWeight s p := (zetaWeight_pos hp0).le
  rw [tsum_congr (fun a => zetaWeight_pow hp0 a)]
  exact tsum_geometric_of_lt_one hnn hlt

/-- The truncated local partition function is strictly below its Euler factor. -/
theorem localZeta_lt_euler_factor {s : ℝ} {p A : ℕ} (hp : 2 ≤ p) (hs : 0 < s) :
    localZeta s p A < (1 - zetaWeight s p)⁻¹ := by
  have hp0 : 0 < p := by omega
  have hlt : zetaWeight s p < 1 := zetaWeight_lt_one hp hs
  have hnn : 0 ≤ zetaWeight s p := (zetaWeight_pos hp0).le
  have hx : 0 < zetaWeight s p ^ (A + 1) := pow_pos (zetaWeight_pos hp0) _
  have hne : zetaWeight s p ≠ 1 := ne_of_lt hlt
  rw [localZeta_geom hp0 hne]
  rw [div_lt_iff_of_neg (by linarith : zetaWeight s p - 1 < 0)]
  have h0 : (1 : ℝ) - zetaWeight s p ≠ 0 := by linarith
  have hinv : (1 - zetaWeight s p)⁻¹ * (zetaWeight s p - 1) = -1 := by
    rw [inv_mul_eq_div, div_eq_iff h0]; ring
  rw [hinv]
  linarith

end RLHF