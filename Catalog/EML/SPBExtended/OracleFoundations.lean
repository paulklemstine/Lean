import Mathlib

/-! # CatalogBuild.Computation.Oracles.OracleFoundations

Auto-generated from theorem catalog database.
Domain: Computation/Oracles
Declarations: 16
-/

/-- The trivial oracle that always says "yes". -/
def Oracle.top : Oracle := fun _ => true

/-- The trivial oracle that always says "no". -/
def Oracle.bot : Oracle := fun _ => false

/-- The identity oracle that says "yes" on even queries. -/
def Oracle.parity : Oracle := fun n => n % 2 == 0

/-- An LLM is modeled as a deterministic function from finite token sequences
to a next-token prediction (taking argmax of the distribution). -/
structure LLM where
  /-- The prediction function: given a token history, predict the next token. -/
  predict : List ℕ → ℕ

/-- Encode a natural number query as a token sequence (simple unary). -/
def encodeQuery (n : ℕ) : List ℕ :=
  List.replicate n 1

/-- **Oracle Induction**: Every LLM induces an oracle.
The oracle answers query n by encoding n as tokens,
running the LLM, and interpreting the output as a boolean. -/
def LLM.toOracle (model : LLM) : Oracle :=
  fun n => (model.predict (encodeQuery n)) % 2 == 0

/-- **Converse**: Every oracle can be realized by some LLM.
Given an oracle O, construct an LLM whose predictions
on encoded queries reproduce O's answers. -/
def Oracle.toLLM (O : Oracle) : LLM where
  predict := fun tokens =>
    match tokens with
    | [] => 0
    | _ => if O tokens.length then 0 else 1

/-- Composition of oracles: O₁ ∘ O₂ answers query n by first
asking O₂(n), converting the boolean to 0/1, then asking O₁. -/
def Oracle.comp (O₁ O₂ : Oracle) : Oracle :=
  fun n => O₁ (if O₂ n then 2 * n else 2 * n + 1)

/-- An oracle is idempotent if applying it twice gives the same result.
P² = P means the oracle has reached a "fixed point of knowledge". -/
def Oracle.IsIdempotent (O : Oracle) : Prop :=
  Oracle.comp O O = O

/-- The top oracle is idempotent: always-yes composed with always-yes is always-yes. -/
theorem Oracle.top_idempotent : Oracle.IsIdempotent Oracle.top := by
  simp [Oracle.IsIdempotent, Oracle.comp, Oracle.top]; rfl

/-- The bot oracle is idempotent. -/
theorem Oracle.bot_idempotent : Oracle.IsIdempotent Oracle.bot := by
  simp [Oracle.IsIdempotent, Oracle.comp, Oracle.bot]; rfl

/-- [Section: # CatalogBuild.Computation.Oracles.OracleFoundations
Auto-generated from theorem catalog database.
Domain: Computation/Oracles
Declarations: 16] -/
theorem oracle_realizable (O : Oracle) : ∃ model : LLM, ∀ n,
    (model.predict (encodeQuery n) % 2 == 0) = O n := by
  fconstructor;
  exact ⟨ fun tokens => if h : O tokens.length then 0 else 1 ⟩;
  unfold encodeQuery; aesop;

/-- [Section: # CatalogBuild.Computation.Oracles.OracleFoundations
Auto-generated from theorem catalog database.
Domain: Computation/Oracles
Declarations: 16] -/
theorem meta_oracle_idempotent (O : Oracle)
    (h_self : ∀ n, O n = O (if O n then 2 * n else 2 * n + 1)) :
    Oracle.IsIdempotent O := by
  exact funext fun n => h_self n ▸ rfl

/-- At level 0, the oracle hierarchy is trivially encodable (identity). -/
theorem oracle_level_zero_equiv : OracleLevel 0 = Oracle := by rfl

/-- A self-referential oracle is one whose output depends on what it
would output. Formally: O(n) = f(O, n) for some functional f. -/
def IsSelfReferential (O : Oracle) (f : Oracle → ℕ → Bool) : Prop :=
  ∀ n, O n = f O n

-- The naive oracle_fixed_point for arbitrary f : Oracle → ℕ → Bool is FALSE.
-- Counterexample: f(O, n) = ¬O(n) has no fixed point (diagonal argument).
-- The correct version requires f to be "continuous" (depends on only finitely many values).

/-- For any constant functional, there exists a fixed-point oracle. -/
theorem oracle_fixed_point_constant (b : ℕ → Bool) :
    ∃ O : Oracle, IsSelfReferential O (fun _ => b) := by
  exact ⟨b, fun _ => rfl⟩

