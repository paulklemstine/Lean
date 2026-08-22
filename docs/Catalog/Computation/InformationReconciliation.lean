/-
# Information Reconciliation: the public transcript, corrected keys, and leakage

Two parties, Alice and Bob, hold binary strings `a b : Fin n → ZMod 2` that agree
except on a small set of positions (the *error pattern* `a - b`).  In a
syndrome-based *information reconciliation* protocol Alice publishes the
syndrome `H *ᵥ a` of her string with respect to a public parity-check matrix
`H : Matrix (Fin m) (Fin n) (ZMod 2)`; this string of `m` bits is the entire
public transcript.  Bob subtracts his own syndrome, decodes the resulting
*error syndrome*, and corrects his string.

This file formalises

* the transcript (`Scheme.transcript`) and Bob's correction map
  (`Scheme.correct`);
* injectivity of the syndrome map on the Hamming ball of radius `t`
  (`Scheme.syndrome_inj_on_ball`) under the minimum-distance hypothesis
  `Scheme.Separating`;
* correctness of the decoder (`Scheme.decode_syndrome`) and of the reconciled
  key (`Scheme.correct_transcript`), i.e. Bob's corrected key *equals* Alice's;
* the fact that the transcript is the *only* thing that goes public: two runs
  with the same transcript are indistinguishable to an eavesdropper
  (`Scheme.transcript_eq_iff_sub_mem_ker`).

Leakage accounting is developed in `Computation.InformationReconciliationLeakage`.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): a syndrome transcript both (i) determines the error
pattern uniquely inside the correction radius and (ii) determines Alice's key
only up to a coset of the code, so correctness and leakage are two readings of
the same fiber structure.

Experiment (Experimenter): exhaustive kernel computation over all `2^n` keys.
For `!![1,1,0; 0,1,1]` (repetition, `n=3, m=2`) every syndrome fiber has size
`2` and all `4` syndromes occur; for the `[7,4]` Hamming matrix every fiber has
size `16` and all `8` syndromes occur, with the `8` weight-`≤1` patterns
realising each syndrome exactly once.  For `!![1,1,0,0; 0,0,1,1]` (`n=4, m=2`)
the nonzero kernel weights are `{2,4}`, and the weight-1 patterns `1000`,
`0100` collide, so unique decoding fails.

Analysis (Analyst): the collision above is precisely the failure of
`2 * t < minimum kernel weight`, which is why `Scheme.Separating` is stated
that way and why it is exactly what `Scheme.syndrome_inj_on_ball` needs.

Critique (Critic): `Scheme.decode` is defined by choice, so correctness must be
proved from injectivity rather than from any decoding algorithm; totality of
decoding is a separate (and strictly stronger) property, proved only for
perfect schemes in `Computation.InformationReconciliationPerfect`.
-/

import Mathlib

open Matrix Finset

namespace InformationReconciliation

/-- A raw key: a binary string of length `n`. -/
abbrev Key (n : ℕ) := Fin n → ZMod 2

/-- A public syndrome: a binary string of length `m`. -/
abbrev Synd (m : ℕ) := Fin m → ZMod 2

/-- A syndrome-based reconciliation scheme: a public parity-check matrix `H`
together with the number `t` of discrepancies the protocol promises to repair. -/
structure Scheme (n m : ℕ) where
  /-- The public parity-check matrix. -/
  H : Matrix (Fin m) (Fin n) (ZMod 2)
  /-- The advertised correction radius. -/
  t : ℕ

variable {n m : ℕ} (S : Scheme n m)

/-- The syndrome of a string. -/
def Scheme.syndrome (x : Key n) : Synd m := S.H *ᵥ x

/-- The public transcript of a run of the protocol: Alice's syndrome. -/
def Scheme.transcript (a : Key n) : Synd m := S.syndrome a

/-- The set of strings consistent with a given transcript. -/
def Scheme.fiber (s : Synd m) : Set (Key n) := {x | S.syndrome x = s}

/-- Strings the scheme is designed to be able to tell apart: the Hamming ball of
radius `t` around `0`. -/
def Scheme.ball : Set (Key n) := {x | hammingNorm x ≤ S.t}

/-- The separation hypothesis: every nonzero kernel vector (i.e. every nonzero
codeword of the code with parity-check matrix `H`) has Hamming weight `> 2 * t`.
This is the usual "minimum distance exceeds twice the correction radius". -/
def Scheme.Separating : Prop :=
  ∀ c : Key n, S.syndrome c = 0 → c ≠ 0 → 2 * S.t < hammingNorm c

variable {S}

@[simp] lemma Scheme.syndrome_zero : S.syndrome (0 : Key n) = 0 := by
  simp [Scheme.syndrome]

lemma Scheme.syndrome_add (x y : Key n) :
    S.syndrome (x + y) = S.syndrome x + S.syndrome y := by
  simp [Scheme.syndrome, mulVec_add]

lemma Scheme.syndrome_sub (x y : Key n) :
    S.syndrome (x - y) = S.syndrome x - S.syndrome y := by
  simp [Scheme.syndrome, mulVec_sub]

/-! ### Hamming weight arithmetic -/

/-- Subadditivity of the Hamming weight along differences. -/
lemma hammingNorm_sub_le (x y : Key n) :
    hammingNorm (x - y) ≤ hammingNorm x + hammingNorm y := by
  have h := hammingDist_triangle x 0 y
  rw [hammingDist_zero_right,
    show hammingDist (0 : Key n) y = hammingNorm y from congrFun hammingDist_zero_left y] at h
  rwa [← hammingDist_eq_hammingNorm]

/-! ### Unique decoding -/

/-- Under the separation hypothesis the syndrome map is injective on the ball of
radius `t`: two error patterns of weight at most `t` with the same syndrome are
equal.  This is the heart of the correctness argument. -/
theorem Scheme.syndrome_inj_on_ball (hS : S.Separating) {x y : Key n}
    (hx : hammingNorm x ≤ S.t) (hy : hammingNorm y ≤ S.t)
    (h : S.syndrome x = S.syndrome y) : x = y := by
  by_contra hne
  have hxy : x - y ≠ 0 := sub_ne_zero_of_ne hne
  have hker : S.syndrome (x - y) = 0 := by rw [Scheme.syndrome_sub, h, sub_self]
  have h1 : 2 * S.t < hammingNorm (x - y) := hS _ hker hxy
  have h2 : hammingNorm (x - y) ≤ hammingNorm x + hammingNorm y := hammingNorm_sub_le x y
  omega

/-- The syndrome decoder: return some string of weight `≤ t` with the given
syndrome, if one exists (and `0` otherwise). -/
noncomputable def Scheme.decode (S : Scheme n m) (s : Synd m) : Key n :=
  if h : ∃ e : Key n, S.syndrome e = s ∧ hammingNorm e ≤ S.t then h.choose else 0

/-- The decoder recovers *the* low-weight error pattern. -/
theorem Scheme.decode_syndrome (hS : S.Separating) {e : Key n}
    (he : hammingNorm e ≤ S.t) : S.decode (S.syndrome e) = e := by
  have hex : ∃ x : Key n, S.syndrome x = S.syndrome e ∧ hammingNorm x ≤ S.t := ⟨e, rfl, he⟩
  rw [Scheme.decode, dif_pos hex]
  obtain ⟨h1, h2⟩ := hex.choose_spec
  exact Scheme.syndrome_inj_on_ball hS h2 he h1

/-! ### The protocol -/

/-- Bob's correction step: given his own string `b` and the public transcript
`s`, he decodes the *difference* of syndromes and adds the result to `b`. -/
noncomputable def Scheme.correct (S : Scheme n m) (b : Key n) (s : Synd m) : Key n :=
  b + S.decode (s - S.syndrome b)

/-- **Correctness of information reconciliation.**  If Alice's and Bob's strings
differ in at most `t` positions and the scheme is separating, then Bob's
corrected key is *exactly* Alice's key. -/
theorem Scheme.correct_transcript (hS : S.Separating) {a b : Key n}
    (hab : hammingNorm (a - b) ≤ S.t) :
    S.correct b (S.transcript a) = a := by
  have hs : S.transcript a - S.syndrome b = S.syndrome (a - b) := by
    rw [Scheme.syndrome_sub]; rfl
  rw [Scheme.correct, hs, Scheme.decode_syndrome hS hab]
  abel

/-- Restated with the error pattern in the foreground: Bob's corrected key is
`a` whenever `a = b + e` for an error `e` of weight at most `t`. -/
theorem Scheme.correct_of_error (hS : S.Separating) (b e : Key n)
    (he : hammingNorm e ≤ S.t) :
    S.correct b (S.transcript (b + e)) = b + e :=
  Scheme.correct_transcript hS (by simpa using he)

/-- Reconciliation is idempotent on agreeing keys: if Bob already holds Alice's
key, the transcript changes nothing. -/
theorem Scheme.correct_self (hS : S.Separating) (a : Key n) :
    S.correct a (S.transcript a) = a :=
  Scheme.correct_transcript hS (by simp)

/-! ### What the transcript determines -/

/-- Two candidate keys produce the same transcript exactly when they differ by a
codeword.  Hence the transcript pins Alice's key down to a coset of the kernel
and to nothing more. -/
theorem Scheme.transcript_eq_iff_sub_mem_ker (a a' : Key n) :
    S.transcript a = S.transcript a' ↔ S.syndrome (a - a') = 0 := by
  rw [Scheme.syndrome_sub, sub_eq_zero]
  rfl

/-- The fiber of a transcript is exactly the coset `a + ker`. -/
theorem Scheme.mem_fiber_iff (a x : Key n) :
    x ∈ S.fiber (S.transcript a) ↔ S.syndrome (x - a) = 0 := by
  rw [Scheme.syndrome_sub, sub_eq_zero]
  rfl

/-- Alice's key always lies in the fiber of its own transcript: the transcript
is consistent. -/
theorem Scheme.self_mem_fiber (a : Key n) : a ∈ S.fiber (S.transcript a) := rfl

end InformationReconciliation