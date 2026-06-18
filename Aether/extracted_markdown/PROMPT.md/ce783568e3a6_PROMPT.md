Formalize a complete, self-contained Lean 4 file proving a concrete bridge theorem between p-adic valuations on natural numbers and tropical threshold-counting profiles. Do not introduce any unfinished structures, classes, or functorial packaging. Work only with explicit definitions and finished theorems.

Target file: Catalog/Tropical/ValuationDepthProfile.lean

Imports: use the minimal Mathlib imports needed, but importing Mathlib is acceptable if it simplifies completion.

Mathematical setup:
- Let ι be a finite type with [Fintype ι].
- Fix p : ℕ.
- Define
  vProfile (p : ℕ) (x : ι → ℕ) (t : ℕ) : ℕ :=
    Fintype.card {i : ι // t < padicValNat p (x i)}.
- Define
  minProfile (p : ℕ) (x y : ι → ℕ) (t : ℕ) : ℕ :=
    Fintype.card {i : ι // t < min (padicValNat p (x i)) (padicValNat p (y i))}.

Required theorems, in this order:

1. vProfile_antitone
Statement: if s ≤ t then vProfile p x t ≤ vProfile p x s.
Proof strategy: use Fintype.card_subtype_mono with the obvious implication t < v -> s < v.

2. minProfile_le_vProfile_left and minProfile_le_vProfile_right
Statements:
  minProfile p x y t ≤ vProfile p x t
  minProfile p x y t ≤ vProfile p y t
Proof strategy: use Fintype.card_subtype_mono and the implications
  t < min a b -> t < a
  t < min a b -> t < b.

3. threshold_add
For a fixed i : ι, prove that
  t < min (padicValNat p (x i)) (padicValNat p (y i)) ->
  t < padicValNat p (x i + y i).
Use the standard nonarchimedean inequality already in Mathlib for padicValNat on naturals. If the exact lemma requires a primality hypothesis on p, include the necessary assumption (for example Nat.Prime p) in all theorems from this point onward. Prefer the weakest assumptions that make the proof go through cleanly.

4. minProfile_le_vProfile_add
Statement:
  minProfile p x y t ≤ vProfile p (fun i => x i + y i) t
again with any necessary prime hypothesis on p.
Proof strategy: use Fintype.card_subtype_mono, reducing to threshold_add coordinatewise.

Additional requirements:
- Keep the file short and complete. No theorem declarations without proofs.
- Avoid defining TropicalValuationProfile or any structure unless it is absolutely necessary; it is not expected here.
- Add concise module documentation explaining the bridge: the profile counts coordinates above a valuation threshold, and the addition inequality induces a tropical-style lower bound on counts.
- If padicValNat addition lemmas have edge conditions involving zero or p = 1, handle them explicitly and transparently in theorem assumptions.
- Prefer theorem names exactly as listed above so this can serve as a completion of the prior partial attempt.
- If a direct strict-threshold statement is awkward, prove an auxiliary lemma from a Mathlib inequality of the form min(...) ≤ ... and convert it to the desired strict inequality by arithmetic on naturals.

Deliver a compiling Lean file only, with all four theorems proved.