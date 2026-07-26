import Mathlib
import Cryptography.ZeroKnowledge.Graph3Coloring

/-!
# Local Checkability and Multi-Round Soundness of Zero-Knowledge Theorem Proving

The zero-knowledge theorem-proving protocol of the mission rests on a
*PCP-style* idea: an (arithmetized) proof is presented so that **a single random
local query** already exposes any flaw. This file abstracts that idea and proves
the soundness-amplification heart of the protocol, then **specializes it back to
the catalog's graph 3-colouring proof system** (`Cryptography.ZeroKnowledge.Graph3Coloring`).

Setup. A *locally checkable certificate* over a finite challenge space `Ω : Finset β`
is a Boolean predicate `check : β → Bool`; challenge `e` passes iff `check e = true`.
The certificate is *globally valid* iff every challenge passes. A single-round
verifier samples `e ∈ Ω` uniformly and accepts iff `e` passes; over `k` independent
rounds it accepts iff all sampled challenges pass.

## Main results

* `accept_card_le` — **single-round soundness (abstract).** If the certificate is
  invalid (some challenge fails), the passing set has at most `|Ω| - 1` elements, so
  the verifier catches the prover with probability at least `1/|Ω|`.
* `kround_soundness` — **(main theorem)** multi-round soundness amplification: if a
  cheating prover, in each of `k` independent rounds, commits to an *invalid*
  certificate, the probability it survives all `k` rounds is at most
  `((|Ω| - 1)/|Ω|)^k`, which tends to `0`.
* `graph3_kround_soundness` — **(main theorem, catalog bridge)** the abstract bound,
  instantiated at the catalog's GMW 3-colouring verifier: a prover committing in each
  round to an *improper* 3-colouring survives all `k` random-edge challenges with
  probability at most `((|E| - 1)/|E|)^k`. This consumes the catalog's
  `ZK.Graph3Coloring.soundness_exists_catch`, upgrading the catalog's single-round
  `soundness_prob` to a full amplification statement.
* `accept_frac_lt_one` — the single-round accepting fraction of an invalid
  certificate is *strictly* below `1`, certifying a genuine soundness gap.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): Local checkability + independent repetition should force
the acceptance probability of any *false* claim to decay geometrically. Surprising
sub-claim: the decay base is exactly `(|Ω|-1)/|Ω|` with *no* structural assumption on
the checker — a single bad location suffices, and independence multiplies the escape
probabilities. This is the abstract skeleton of "the PCP theorem makes proofs
locally checkable" specialized to the honest combinatorial core.

Experiment (Experimenter): Modeled a round's surviving challenges as
`Ω.filter (check · = true)` and bounded its card by `|Ω| - 1` via an embedding into
`Ω.erase e` for a failing `e` (`Finset.card_erase_of_mem`). Lifted to `k` rounds by
`Finset.prod_le_prod` against the constant `(|Ω|-1)/|Ω|`, then `Finset.prod_const`.
Bridged to the catalog by taking `check e := decide (c e.1 ≠ c e.2)`: an improper
colouring yields a failing edge through `soundness_exists_catch`, and the passing set
is exactly the distinct-colour edges.

Analysis (Analyst): The amplification is *tight* — a prover corrupting exactly one of
`|Ω|` locations survives with probability `(|Ω|-1)/|Ω|` per round — so error `2^{-k}`
requires `Θ(|Ω| · k)` rounds when `|Ω|` is large, sharpening the mission's blanket
`2^{-k}` claim. The catalog previously proved only the *single-round* gap
(`soundness_prob`); the genuine extension here is (a) the abstract local-check
formulation and (b) its `k`-round product, from which the catalog result is the
`k = 1` shadow.

Critique (Critic): No result is `True`-shaped or `decide`-only. `kround_soundness`
is a real product inequality proved with `Finset.prod_le_prod`/`gcongr`;
`graph3_kround_soundness` genuinely imports and applies a catalog lemma (not a
re-proof) and is non-vacuous for `|E| ≥ 1`; `accept_frac_lt_one` needs the failing
challenge to make the inequality strict.

Synthesis (PI): One local query catches any flaw with probability `≥ 1/|Ω|`;
independent repetition drives soundness error to `0`. Combined with the Merkle
commitment file (binding the queried step) this is the full soundness story of a
zero-knowledge theorem-proving protocol.
-- !-- Lab Notes -- !--
-/

namespace ZK.LocalCheck

open Finset

variable {β : Type*} [DecidableEq β]

/-! ## Single-round soundness (abstract) -/

/-- **Single-round soundness.** If some challenge `e ∈ Ω` *fails* the local check,
then the set of *passing* challenges has at most `|Ω| - 1` elements. Hence a verifier
sampling a uniformly random challenge catches the cheating prover with probability at
least `1/|Ω|`. -/
theorem accept_card_le (Ω : Finset β) (check : β → Bool)
    (h : ∃ e ∈ Ω, check e = false) :
    (Ω.filter (fun e => check e = true)).card ≤ Ω.card - 1 := by
  obtain ⟨e, heΩ, he⟩ := h
  have hsub : Ω.filter (fun e => check e = true) ⊆ Ω.erase e := by
    intro x hx
    simp only [mem_filter] at hx
    rw [mem_erase]
    refine ⟨?_, hx.1⟩
    rintro rfl
    rw [he] at hx; simp at hx
  calc (Ω.filter (fun e => check e = true)).card
      ≤ (Ω.erase e).card := Finset.card_le_card hsub
    _ = Ω.card - 1 := Finset.card_erase_of_mem heΩ

/-- **Strict soundness gap.** For an invalid certificate on a nonempty challenge
space, the accepting fraction is *strictly* less than `1`. -/
theorem accept_frac_lt_one (Ω : Finset β) (hΩ : 0 < Ω.card) (check : β → Bool)
    (h : ∃ e ∈ Ω, check e = false) :
    ((Ω.filter (fun e => check e = true)).card : ℚ) / Ω.card < 1 := by
  have hq : (0 : ℚ) < Ω.card := by exact_mod_cast hΩ
  rw [div_lt_one hq]
  have hc := accept_card_le Ω check h
  have : ((Ω.filter (fun e => check e = true)).card : ℚ) ≤ (Ω.card : ℚ) - 1 := by
    have := (Nat.cast_le (α := ℚ)).mpr hc
    rwa [Nat.cast_sub hΩ, Nat.cast_one] at this
  linarith

/-! ## Multi-round soundness amplification -/

/-- **Multi-round soundness amplification (abstract).** If in each of `k` independent
rounds the prover commits to an *invalid* certificate `checks i`, then the probability
it survives all `k` rounds — the product of the per-round accepting fractions — is at
most `((|Ω| - 1)/|Ω|)^k`. Since `(|Ω|-1)/|Ω| < 1`, the soundness error decays
geometrically to `0`. -/
theorem kround_soundness (Ω : Finset β) (hΩ : 0 < Ω.card) {k : ℕ}
    (checks : Fin k → (β → Bool))
    (h : ∀ i, ∃ e ∈ Ω, checks i e = false) :
    ∏ i, ((Ω.filter (fun e => checks i e = true)).card : ℚ) / Ω.card
      ≤ (((Ω.card : ℚ) - 1) / Ω.card) ^ k := by
  calc ∏ i, ((Ω.filter (fun e => checks i e = true)).card : ℚ) / Ω.card
      ≤ ∏ _i : Fin k, (((Ω.card : ℚ) - 1) / Ω.card) := by
        apply Finset.prod_le_prod
        · intro i _; positivity
        · intro i _
          have hc := accept_card_le Ω (checks i) (h i)
          have hcast : ((Ω.filter (fun e => checks i e = true)).card : ℚ)
              ≤ (Ω.card : ℚ) - 1 := by
            have := (Nat.cast_le (α := ℚ)).mpr hc
            rwa [Nat.cast_sub hΩ, Nat.cast_one] at this
          gcongr
    _ = (((Ω.card : ℚ) - 1) / Ω.card) ^ k := by
        rw [Finset.prod_const, Finset.card_univ, Fintype.card_fin]

/-! ## Catalog bridge: `k`-round soundness of GMW graph 3-colouring -/

variable {V : Type*} [DecidableEq V]

/-- **Main theorem (catalog-bridged amplification).** Instantiate the abstract
local-check soundness at the catalog's GMW 3-colouring verifier: the challenge space
is the edge set `E`, and edge `e` passes iff its endpoints get distinct colours. If a
cheating prover commits, in each of `k` independent rounds, to an *improper* colouring
`colorings i`, then it survives all `k` random-edge challenges with probability at most
`((|E| - 1)/|E|)^k`.

This *uses* the catalog file `Graph3Coloring`: improperness yields a failing edge via
`ZK.Graph3Coloring.soundness_exists_catch`, and the passing edges are exactly the
distinct-colour edges. It upgrades the catalog's single-round `soundness_prob` to a
full soundness-amplification theorem. -/
theorem graph3_kround_soundness {k : ℕ} (E : Finset (V × V)) (hE : 0 < E.card)
    (colorings : Fin k → (V → Fin 3))
    (h : ∀ i, ¬ ZK.Graph3Coloring.IsProperColoring E (colorings i)) :
    ∏ i, ((E.filter (fun e => colorings i e.1 ≠ colorings i e.2)).card : ℚ) / E.card
      ≤ (((E.card : ℚ) - 1) / E.card) ^ k := by
  -- local checker: edge passes iff its endpoints get distinct colours
  set checks : Fin k → (V × V → Bool) :=
    fun i e => decide (colorings i e.1 ≠ colorings i e.2) with hchecks
  -- each round's checker fails on some edge (an improperly coloured one)
  have hfail : ∀ i, ∃ e ∈ E, checks i e = false := by
    intro i
    obtain ⟨e, heE, hee⟩ := ZK.Graph3Coloring.soundness_exists_catch E (colorings i) (h i)
    exact ⟨e, heE, by simp [hchecks, hee]⟩
  -- the passing edges are exactly the distinct-colour edges
  have hfilter : ∀ i, E.filter (fun e => checks i e = true)
      = E.filter (fun e => colorings i e.1 ≠ colorings i e.2) := by
    intro i
    apply Finset.filter_congr
    intro e _
    simp [hchecks]
  have hmain := kround_soundness E hE checks hfail
  simpa only [hfilter] using hmain

end ZK.LocalCheck