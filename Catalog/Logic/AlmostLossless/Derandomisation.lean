import Logic.AlmostLossless.Instances

/-!
# Derandomisation: from Monte Carlo to a deterministic zero-failure compressor

The Monte-Carlo scheme of `Logic.AlmostLossless.Scheme` fails with probability
`≤ ε + |T|(|T|-1)/|M|` over the random seed.  The probabilistic method converts
this into a *deterministic* statement: as soon as `|M| > |T|(|T|-1)` some seed
hashes the whole typical set injectively, and then the compressor never fails on
a typical word at all.  The random number generator is only a proof device; it
can be dispensed with.

The price is the **birthday penalty**: a 2-universal family needs a range of
size about `|T|²`, whereas the exact `ε`-pigeonhole characterisation
(`AlmostLossless.epsilon_pigeonhole_iff`) says `|T|` symbols suffice
information-theoretically.  Bertrand's postulate lets us pin this down:

> `AlmostLossless.exists_quadratic_rate_scanScheme` — for every finite source
> alphabet and every typical set `T` there is a prime `p ≤ 2|T|²` and an
> explicit inner-product hash such that the induced scan code is honest, decodes
> **every** typical word correctly, uses only `p + 1 ≤ 2|T|² + 1` codeword
> symbols and decodes in exactly `|T|` hash evaluations.

So the constructive, checksum-free, never-silently-wrong compressor costs at
most *twice the square* of the information-theoretic alphabet size — a factor
`2` in rate, in exchange for an explicit decoder.
-/

namespace AlmostLossless

open Finset

/-! ## Pulling a hash family back along an embedding -/

/-- Two-universality is preserved by precomposition with an injection: any
finite source can be hashed by embedding it into `(ZMod p)^k` first. -/
theorem TwoUniversal.comp_embedding {S S' A M : Type*} [Fintype A] [DecidableEq A]
    [Fintype M] [DecidableEq M] {h : A → S' → M} (hu : TwoUniversal h) (ι : S ↪ S') :
    TwoUniversal (fun a (s : S) => h a (ι s)) := by
  intro x y hxy
  exact hu (ι x) (ι y) (fun hc => hxy (ι.injective hc))

/-! ## The deterministic compressor -/

variable {S : Type*} [Fintype S] [DecidableEq S]

omit [Fintype S] in
/-- **Derandomised scheme.**  If the hash range beats the number of ordered
pairs of typical words, some seed makes the scan code decode *every* typical
word correctly — with zero failure probability on the typical set, honest as
always, and cost exactly `|T|`. -/
theorem exists_perfect_scanScheme {A M : Type*} [Fintype A] [DecidableEq A] [Nonempty A]
    [Fintype M] [DecidableEq M] [Nonempty M] (T : Finset S) {h : A → S → M}
    (hu : TwoUniversal h) (hlt : T.offDiag.card < Fintype.card M) :
    ∃ a : A, Honest ((linearScan T h).code a) ∧
      (∀ s ∈ T, Correct ((linearScan T h).code a) s) ∧
      (∀ m : M, (linearScan T h).decodeCost a m = T.card) := by
  obtain ⟨a, ha⟩ := exists_perfect_seed hu T hlt
  exact ⟨a, honest_scanCode _ a, fun s hs => correct_scanCode _ a ha hs, fun _ => rfl⟩

/-- Derandomised failure probability: *zero* on the typical set, hence at most
`ε` overall, deterministically. -/
theorem exists_deterministic_failProb_le {A M : Type*} [Fintype A] [DecidableEq A] [Nonempty A]
    [Fintype M] [DecidableEq M] [Nonempty M] (μ : Source S) (T : Finset S) {h : A → S → M}
    (hu : TwoUniversal h) (hlt : T.offDiag.card < Fintype.card M) (ε : ℚ)
    (hT : 1 - ε ≤ μ.prob T) :
    ∃ a : A, failProb μ ((linearScan T h).code a) ≤ ε := by
  obtain ⟨a, _, hcor, _⟩ := exists_perfect_scanScheme T hu hlt
  exact ⟨a, failProb_le_of_correct_on μ _ T hcor ε hT⟩

/-! ## Quadratic rate via Bertrand's postulate -/

omit [DecidableEq S] in
/-- Any finite type embeds into `(ZMod p)^{|S|}` for `p ≥ 2`. -/
theorem exists_embedding_zmod (p : ℕ) (hp : 2 ≤ p) :
    Nonempty (S ↪ (Fin (Fintype.card S) → ZMod p)) := by
  haveI : NeZero p := ⟨by omega⟩
  refine Function.Embedding.nonempty_of_card_le ?_
  have hcard : Fintype.card (Fin (Fintype.card S) → ZMod p) = p ^ Fintype.card S := by
    simp [ZMod.card]
  rw [hcard]
  calc Fintype.card S ≤ 2 ^ Fintype.card S := (Nat.lt_two_pow_self).le
    _ ≤ p ^ Fintype.card S := Nat.pow_le_pow_left hp _

/-- **The rate–determinism trade-off, quantified.**  For every typical set `T`
of a finite source there is a prime `p ≤ 2|T|²` and an explicit inner-product
hash scheme over `ZMod p` whose scan code is honest, decodes every typical word
correctly, and costs exactly `|T|` hash evaluations, while transmitting one of
only `p + 1` symbols.

Against the information-theoretic optimum `|T|` symbols
(`epsilon_pigeonhole_iff`), the constructive scheme pays a squaring — the
birthday penalty of pairwise-independent hashing — and nothing more. -/
theorem exists_quadratic_rate_scanScheme (T : Finset S) (hT : T.Nonempty) :
    ∃ p : ℕ, p.Prime ∧ T.card ^ 2 < p ∧ p ≤ 2 * T.card ^ 2 ∧
      ∃ (a : Fin (Fintype.card S) → ZMod p)
        (P : ScanScheme S (Fin (Fintype.card S) → ZMod p) (ZMod p)),
        P.typical = T ∧ Honest (P.code a) ∧ (∀ s ∈ T, Correct (P.code a) s) ∧
        (∀ m : ZMod p, P.decodeCost a m = T.card) := by
  classical
  have hTpos : 0 < T.card := Finset.card_pos.2 hT
  obtain ⟨p, hp, hlt, hle⟩ :=
    Nat.exists_prime_lt_and_le_two_mul (n := T.card ^ 2) (by positivity)
  haveI : Fact p.Prime := ⟨hp⟩
  haveI : NeZero p := ⟨hp.pos.ne'⟩
  obtain ⟨ι⟩ := exists_embedding_zmod (S := S) p hp.two_le
  set k := Fintype.card S with hk
  set h : (Fin k → ZMod p) → S → ZMod p := fun a s => dotHash p k a (ι s) with hh
  have hu : TwoUniversal h := (twoUniversal_dotHash).comp_embedding ι
  have hoff : T.offDiag.card < Fintype.card (ZMod p) := by
    rw [ZMod.card]
    have hc : T.offDiag.card = T.card * T.card - T.card := Finset.offDiag_card T
    have hsq : T.card ^ 2 = T.card * T.card := sq T.card
    omega
  obtain ⟨a, hhon, hcor, hcost⟩ := exists_perfect_scanScheme T hu hoff
  exact ⟨p, hp, hlt, hle, a, linearScan T h, rfl, hhon, hcor, hcost⟩

end AlmostLossless