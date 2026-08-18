/-
# The Price of Universality VII: a multi-dimensional Rissanen lower bound

Research thread *Compression Beyond the Pigeonhole Bound*, Phase A, Question 1.

`MachineLearning.UniversalRedundancy.Bernoulli` proves the Rissanen-style lower
bound `Cₛ ≥ √n / 4` for the *binary* memoryless class — one free parameter, one
half of a `log₂ n`.  Nothing in the catalog gave a lower bound growing with the
alphabet.

Here we obtain one by a tensorization trick.  Take the alphabet
`A = Fin k → Bool` (`#A = 2 ^ k`).  A message of length `n` over `A` *is* a
`k`-tuple of binary strings of length `n`, and every `k`-tuple of Bernoulli
parameters gives a memoryless source over `A` with product marginals.  So the
memoryless class over `A` contains a copy of the `k`-fold power of the binary
memoryless class, and the multiplicativity of the Shtarkov sum
(`Logic.PriceOfUniversality.Tensor`) transfers the binary bound:

`Cₛ(iid over A, length n) ≥ (√n / 4) ^ k`,  i.e.  price `≥ k (½ log₂ n − 2)`.

Combined with the type bound at the Rissanen dimension
(`Logic.PriceOfUniversality.TypeDimension`) this sandwiches the price of
universality of a memoryless class over a `2^k`-letter alphabet between
`k (½ log₂ n − 2)` and `(2^k − 1) log₂ (n+1)`: **logarithmic in the message
length `n` for every alphabet, with an alphabet-dependent constant that is
genuinely unbounded**.

## Main results

* `productParam` — a `k`-tuple of Bernoulli parameters as a memoryless source
  over `Fin k → Bool`
* `power_maxLik_le_iid` — the power class embeds into the memoryless class
* `shtarkovSum_power_le_iid` — `Cₛ((binary iid)^k) ≤ Cₛ(iid over Fin k → Bool)`
* `shtarkovSum_iidClass_pow_ge` — `(√n/4)^k ≤ Cₛ`
* `iid_price_multialphabet_lower` — bit form: price `≥ k (½ log₂ n − 2)`
* `iid_price_multialphabet_sandwich` — the two-sided statement

## Application keywords

Rissanen redundancy, minimax universal coding, tensorization, method of types,
parameter dimension
-/

import Logic.PriceOfUniversality.Tensor

open Finset Real

namespace UniversalRedundancy

variable {k n : ℕ}

/-- A `k`-tuple of Bernoulli parameters, read as a memoryless source over the
alphabet `Fin k → Bool` with independent coordinates. -/
noncomputable def productParam (θ : Fin k → Simplex Bool) : Simplex (Fin k → Bool) :=
  ⟨fun a => ∏ i, (θ i).1 (a i), fun a => Finset.prod_nonneg fun i _ => (θ i).2.1 _, by
    classical
    have h := Finset.prod_univ_sum (fun _ : Fin k => (univ : Finset Bool))
      (fun i (b : Bool) => (θ i).1 b)
    simp only [Fintype.piFinset_univ, (fun i => (θ i).2.2), Finset.prod_const_one] at h
    simpa using h.symm⟩

/-- The likelihood of a message over `Fin k → Bool` under a product parameter is
the product of the `k` binary likelihoods of its coordinate strings. -/
lemma prob_productParam (θ : Fin k → Simplex Bool) (x : Fin n → Fin k → Bool) :
    (iidClass (Fin k → Bool) n).prob (productParam θ) x
      = ((iidClass Bool n).power k).prob θ (fun i j => x j i) := by
  show (∏ j, ∏ i, (θ i).1 (x j i)) = ∏ i, ∏ j, (θ i).1 (x j i)
  exact Finset.prod_comm

/-- Each maximum likelihood of the power of the binary class is dominated by the
maximum likelihood of the memoryless class over `Fin k → Bool`. -/
lemma power_maxLik_le_iid (y : Fin k → Fin n → Bool) :
    ((iidClass Bool n).power k).maxLik y
      ≤ (iidClass (Fin k → Bool) n).maxLik (fun j i => y i j) := by
  refine ((iidClass Bool n).power k).maxLik_le fun θ => ?_
  have h := prob_productParam (n := n) θ (fun j i => y i j)
  simp only at h
  rw [← h]
  exact (iidClass (Fin k → Bool) n).le_maxLik (productParam θ) _

/-- **The power of the binary class embeds into the memoryless class over
`Fin k → Bool`**, at the level of Shtarkov sums. -/
theorem shtarkovSum_power_le_iid (k n : ℕ) :
    ((iidClass Bool n).power k).shtarkovSum
      ≤ (iidClass (Fin k → Bool) n).shtarkovSum := by
  classical
  have hswap : ∑ y : Fin k → Fin n → Bool,
      (iidClass (Fin k → Bool) n).maxLik (fun j i => y i j)
        = ∑ x : Fin n → Fin k → Bool, (iidClass (Fin k → Bool) n).maxLik x :=
    Equiv.sum_comp (Equiv.piComm fun (_ : Fin k) (_ : Fin n) => Bool)
      (iidClass (Fin k → Bool) n).maxLik
  calc ((iidClass Bool n).power k).shtarkovSum
      = ∑ y : Fin k → Fin n → Bool, ((iidClass Bool n).power k).maxLik y := rfl
    _ ≤ ∑ y : Fin k → Fin n → Bool,
          (iidClass (Fin k → Bool) n).maxLik (fun j i => y i j) :=
        Finset.sum_le_sum fun y _ => power_maxLik_le_iid y
    _ = (iidClass (Fin k → Bool) n).shtarkovSum := hswap

/-- **The multi-dimensional Rissanen lower bound.**  For an alphabet of size
`2 ^ k` the Shtarkov sum of the memoryless class on messages of length `n ≥ 2`
is at least `(√n / 4) ^ k`. -/
theorem shtarkovSum_iidClass_pow_ge (k n : ℕ) (hn : 2 ≤ n) :
    (Real.sqrt n / 4) ^ k ≤ (iidClass (Fin k → Bool) n).shtarkovSum := by
  have hbin := sqrt_le_shtarkovSum_bernoulli n hn
  have hnn : (0 : ℝ) ≤ Real.sqrt n / 4 := by positivity
  have hpow : (Real.sqrt n / 4) ^ k ≤ ((iidClass Bool n).shtarkovSum) ^ k :=
    pow_le_pow_left₀ hnn hbin k
  have hpower := (iidClass Bool n).shtarkovSum_power (Θ := Simplex Bool) k
  have hembed := shtarkovSum_power_le_iid k n
  rw [hpower] at hembed
  linarith

/-- **The price of universality grows with the alphabet.**  For the memoryless
class over an alphabet of size `2 ^ k` and messages of length `n ≥ 2`, every
universal code pays at least `k (½ log₂ n − 2)` bits against the code tailored
to the true source. -/
theorem iid_price_multialphabet_lower (k n : ℕ) (hn : 2 ≤ n) :
    (k : ℝ) * ((1 / 2) * logb 2 n - 2)
      ≤ logb 2 (iidClass (Fin k → Bool) n).shtarkovSum := by
  have hn0 : (0 : ℝ) < (n : ℝ) := by
    have : 0 < n := by omega
    exact_mod_cast this
  have hbase : (0 : ℝ) < Real.sqrt n / 4 := by positivity
  have hge := shtarkovSum_iidClass_pow_ge k n hn
  have hlog : logb 2 ((Real.sqrt n / 4) ^ k)
      ≤ logb 2 (iidClass (Fin k → Bool) n).shtarkovSum :=
    Real.logb_le_logb_of_le (by norm_num) (by positivity) hge
  have hsplit : logb 2 (Real.sqrt n / 4) = (1 / 2) * logb 2 n - 2 := by
    rw [Real.logb_div (by positivity) (by norm_num)]
    have h1 : logb 2 (Real.sqrt n) = (1 / 2) * logb 2 n := by
      unfold Real.logb
      rw [Real.log_sqrt hn0.le]
      ring
    have h2 : logb 2 (4 : ℝ) = 2 := by
      rw [show (4 : ℝ) = 2 ^ (2 : ℕ) by norm_num, Real.logb_pow,
        Real.logb_self_eq_one] <;> norm_num
    rw [h1, h2]
  rw [Real.logb_pow, hsplit] at hlog
  exact hlog

/-- **The price of universality of a memoryless class is `Θ(log n)` with an
unbounded alphabet-dependent constant.**  Over an alphabet of size `2 ^ k`:

`k (½ log₂ n − 2) ≤ log₂ Cₛ ≤ (2 ^ k − 1) log₂ (n + 1)`.

Both sides are logarithmic in the message length — so universality costs a
vanishing *fraction* of a long message — but the constant grows with the
alphabet at least linearly in the number of binary coordinates `k = log₂ #A`,
and at most like the parameter dimension `#A − 1`. -/
theorem iid_price_multialphabet_sandwich (k n : ℕ) (hn : 2 ≤ n) :
    (k : ℝ) * ((1 / 2) * logb 2 n - 2)
        ≤ logb 2 (iidClass (Fin k → Bool) n).shtarkovSum ∧
      logb 2 (iidClass (Fin k → Bool) n).shtarkovSum
        ≤ ((2 ^ k : ℝ) - 1) * logb 2 ((n : ℝ) + 1) := by
  refine ⟨iid_price_multialphabet_lower k n hn, ?_⟩
  have h := iid_price_le_dim_bits (A := Fin k → Bool) n
  have hcard : (Fintype.card (Fin k → Bool) : ℝ) = 2 ^ k := by
    simp
  rwa [hcard] at h

end UniversalRedundancy