/-! # CatalogBuild.Speculative.FactoringEnergyLandscape

Auto-generated from theorem catalog database.
Domain: Speculative
Declarations: 10
-/

import Mathlib

noncomputable section

/-- [Section: # CatalogBuild.Speculative.FactoringEnergyLandscape
Auto-generated from theorem catalog database.
Domain: Speculative
Declarations: 10] -/
def factoring_energy (N x : ℕ) : ℕ := N % x



theorem energy_zero_iff_factor (N x : ℕ) (hx : 0 < x) :
    factoring_energy N x = 0 ↔ x ∣ N := by
  unfold factoring_energy; exact Nat.dvd_iff_mod_eq_zero.symm



theorem energy_upper_bound (N x : ℕ) (hx : 0 < x) :
    factoring_energy N x < x := Nat.mod_lt N hx



theorem factor_set_is_zero_energy (N x : ℕ) (hx : 0 < x) (hdvd : x ∣ N) :
    factoring_energy N x = 0 := (energy_zero_iff_factor N x hx).mpr hdvd



theorem factor_count_finite (N : ℕ) (hN : 0 < N) : N.divisors.card > 0 :=
  Finset.card_pos.mpr ⟨1, Nat.mem_divisors.mpr ⟨one_dvd N, by omega⟩⟩



theorem semiprime_four_minima (p q : ℕ) (hp : Nat.Prime p) (hq : Nat.Prime q)
    (hpq : p ≠ q) :
    (p * q).divisors.card = 4 := by
  -- The set of divisors of $pq$ is $\{1, p, q, pq\}$.
  have h_divisors_set : Nat.divisors (p * q) = {1, p, q, p * q} := by
    rw [ Nat.divisors_mul, hp.divisors, hq.divisors ];
    simpa [ Finset.ext_iff, Finset.mem_mul ] using by tauto;
  rw [ h_divisors_set, Finset.card_insert_of_notMem, Finset.card_insert_of_notMem, Finset.card_insert_of_notMem ] <;> norm_num [ hp.ne_zero, hq.ne_zero, hp.ne_one, hq.ne_one, hpq ];
  exact ⟨ Ne.symm hp.ne_one, Ne.symm hq.ne_one, Nat.ne_of_lt ( one_lt_mul'' hp.one_lt hq.one_lt ) ⟩



noncomputable def partition_count (N t : ℕ) : ℕ :=
  (Finset.range N).filter (fun x => N % (x + 1) ≤ t) |>.card



theorem energy_near_factor (N d : ℕ) (hd : d ∣ N) (hd_pos : 0 < d) :
    factoring_energy N d = 0 := factor_set_is_zero_energy N d hd_pos hd



theorem energy_at_predecessor (N : ℕ) (hN : 2 < N) :
    factoring_energy N (N - 1) = 1 := by
  rcases N with ( _ | _ | _ | _ | N ) <;> simp_all +arith +decide [ factoring_energy ];
  norm_num [ ( by ring : N + 4 = N + 3 + 1 ) ]



theorem gradient_at_factor (N d : ℕ) (hd : d ∣ N) (hd_pos : 0 < d)
    (hd_lt : d < N) :
    energy_gradient N d = (N % (d + 1) : ℤ) := by
  unfold energy_gradient;
  unfold factoring_energy;
  cases hd ; aesop


end
