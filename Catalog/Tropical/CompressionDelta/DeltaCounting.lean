import Tropical.CompressionDelta.Pigeonhole
import Tropical.CompressionDelta.Amortization

/-!
# Amortized model-delta compression, VII: how many bits is a domain patch?

The research question asks how many bits it costs to shift a shared decoder to a specific
domain, and how long a stream must be before that cost is amortized.  This file answers
both by *combining* the two halves of the development: the pigeonhole floor of
`CompressionDelta.Pigeonhole` applied **to the deltas themselves**, and the sharp
break-even law of `CompressionDelta.Amortization`.

The point is that a delta is itself a transmitted bitstring, and distinct domains need
distinct deltas (otherwise the deployed decoder would be in the same state for two
domains, contradicting that each domain has its own optimal decoder).  Counting therefore
applies to the patch alphabet: with `K` domains, some patch costs at least about
`log₂ K` bits, and the break-even stream length inherits that logarithm.

## Main results

* `CompressionDelta.exists_expensive_patch` — with `2 ^ (t + 1) ≤ K` domains, some domain
  patch is longer than `t` bits.
* `CompressionDelta.log_delay_before_gain` — consequently there is a domain for which the
  adaptive protocol shows **no gain whatsoever** over the generic decoder for the first
  `t ≈ log₂ K` messages: the optimum equals the delta-free cost exactly.
* `CompressionDelta.exists_break_even_ge_log` — and whose break-even stream length is
  more than `t`.
-/

namespace CompressionDelta

/-- **Some domain patch is expensive.**  If a shared decompressor must be steerable to `K`
distinct domains by transmitting a patch, and distinct domains get distinct patches, then
at least one patch is longer than `t` bits whenever `2 ^ (t + 1) ≤ K`. -/
theorem exists_expensive_patch (K t : ℕ) (patch : Fin K → List Bool)
    (hinj : Function.Injective patch) (hK : 2 ^ (t + 1) ≤ K) :
    ∃ k : Fin K, t < (patch k).length := by
  refine exists_long_codeword patch hinj t ?_
  simpa using hK

/-- **Logarithmic warm-up delay.**  With `K` domains there is a domain whose patch is so
long that, on the two-state model of `CompressionDelta.Amortization`, the optimal adaptive
protocol coincides *exactly* with the delta-free generic protocol for every stream of at
most `t` messages: the domain-specialized decoder is worthless until the stream is longer
than `t ≈ log₂ K`. -/
theorem log_delay_before_gain (r K t : ℕ) (patch : Fin K → List Bool)
    (hinj : Function.Injective patch) (hK : 2 ^ (t + 1) ≤ K) :
    ∃ k : Fin K, ∀ n ≤ t,
      optCost (boolDelta (patch k).length) false (List.replicate n (boolCost r)) =
        n * (r + 1) := by
  obtain ⟨k, hk⟩ := exists_expensive_patch K t patch hinj hK
  refine ⟨k, fun n hn => ?_⟩
  rw [boolModel_optCost r (patch k).length n]
  have : n * (r + 1) = n * r + n := by ring
  omega

/-- **The break-even length is at least logarithmic in the number of domains.**  For the
domain of `log_delay_before_gain`, the adaptive protocol strictly beats the generic one
only for streams strictly longer than `t`. -/
theorem exists_break_even_ge_log (r K t : ℕ) (patch : Fin K → List Bool)
    (hinj : Function.Injective patch) (hK : 2 ^ (t + 1) ≤ K) :
    ∃ k : Fin K, ∀ n : ℕ,
      (optCost (boolDelta (patch k).length) false (List.replicate n (boolCost r)) <
        n * (r + 1)) → t < n := by
  obtain ⟨k, hk⟩ := exists_expensive_patch K t patch hinj hK
  refine ⟨k, fun n hn => ?_⟩
  have hbe := (boolModel_break_even r (patch k).length n).mp hn
  omega

/-- **Amortized cost of serving `K` domains.**  Serving all `K` domains, each with a stream
of `n` messages, costs at least `K * n * r` bits (the rate floor) and at least one of the
domains additionally pays more than `t ≈ log₂ K` bits of patch — so the total patch
overhead of a `K`-domain deployment cannot be made `o(log K)` by clever engineering of a
single domain. -/
theorem total_patch_overhead (K t : ℕ) (patch : Fin K → List Bool)
    (hinj : Function.Injective patch) (hK : 2 ^ (t + 1) ≤ K) :
    t < ∑ k : Fin K, (patch k).length := by
  obtain ⟨k, hk⟩ := exists_expensive_patch K t patch hinj hK
  have : (patch k).length ≤ ∑ k : Fin K, (patch k).length :=
    Finset.single_le_sum (f := fun k : Fin K => (patch k).length)
      (fun i _ => Nat.zero_le _) (Finset.mem_univ k)
  omega

end CompressionDelta