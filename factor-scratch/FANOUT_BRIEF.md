# Shared brief for factoring subagents (round 112 fan-out)

Read this before writing any code. Every item below was learned the hard way in
rounds 44–111 and several of them produced *confidently wrong published numbers*
before being caught. You are not repeating those rounds.

## 0. What counts as success

**A rigorous kill is a success.** This campaign has ~55 rounds of mostly
negative results and that is the correct outcome. Do NOT manufacture a positive.
Every prior round that "found something" and was later retracted cost more
credibility than a clean null. Report what is actually true.

Your deliverable is a **falsifiable claim + the experiment that would kill it**,
plus the honest status: SUPPORTED / REFUTED / INCONCLUSIVE / BLOCKED.

## 1. Verification discipline (non-negotiable)

1. **Ground truth first.** Any factor claim must be checked by multiplying the
   reported factors back to N. Never trust a library's factor routine as ground
   truth — `PARI ellcard` silently returns N+1 on composite N (0/6 matched real
   factors in our regime). Validate any ground-truth library in the regime you
   use it.
2. **Negative control.** Before claiming a NULL result, show the harness detects
   a KNOWN planted case. A harness that has never been shown to fire has not
   measured anything (one round was 100% pigeonhole and was called a measurement).
3. **Run every count twice.** Unseeded counts drift between runs (13/40 then
   12/40; 17/40 withdrawn). Publish a count only from a fixed seed, and re-run.
4. **Cite only what you fetched.** Fabricated citations propagate from agent to
   subagent; we have 16 known phantoms. Any mechanism or cost claim needs a URL
   you actually fetched plus a verbatim quote. If you cannot fetch it, say
   "unverified" — do not cite from memory.
5. **Check whether the result already exists** before "discovering" it.

## 2. Environment

SageMath is available (this was NOT available before this session; use it):

    /tmp/mamba/envs/sage/bin/sage        # Sage 10.7
    ~/sage_mamba/envs/sage/bin/sage       # Sage 10.9 (durable; /tmp is not)

Always pass a `timeout` to Bash calls. Use `~/sage_mamba` for anything you want
to survive a reboot — `/tmp` is tmpfs on this box.

Python: `fpylll` is installed and works for LLL. Sage's `L.LLL(0.8)` is exact and
now known to be reproducible (verified across Sage 10.7 and 10.9).

## 3. Traps that have already bitten us

- **`exec()` of a `.sage` file or fragment SKIPS the Sage preparser.** It does
  not error — it silently computes the wrong thing. One refactor turned a
  verified 20/20 into 0/20 on identical seeds. Keep `.sage` scripts
  self-contained and let `sage file.sage` preparse them. Never exec a fragment.
- **Bit budgets must land on exact integers.** `gifp_ref/gifp.sage`'s generator
  returns `None` for EVERY seed unless `n*param` is integral; a full sweep scored
  0/0 for this reason. Snap parameters to a 1/n grid.
- **`inverse_mod` raises `ZeroDivisionError`** when gcd≠1 — inapplicable, not a
  refutation. Guard it.
- **Float cube-root / floor traps.** `int(n**(1/3))` understates `floor(n^(1/3))`
  at every perfect cube; this once manufactured a fake "rigorous refutation".
  Test at the tightest case, not a representative one.
- **`pdftotext` silently flattens superscripts and inverts fractions.** Re-read
  page images before trusting any formula from a PDF (caused 2 wrong derivations).
- **`mono.exponents()` is in parent-ring order**, not `poly.variables()` order.

## 4. Ground already covered — do not re-tread

These are CLOSED. Cite them as closed; do not redo them:

- **NFS relation geometry** (r47 FINAL): closed by a dimensional argument. The
  equation h(a)=g² costs d−2 dimensions, giving genus 1/5/17/49. Two "live
  directions" in the old record were a phantom and a closed axis.
- **Classical-deterministic factoring axis** (r45): abandoned as out-of-scope.
- **LLL is exactly optimal on NFS lattices**: 40/40 rows gave LLL/SVP =
  1.0000000000. No BKZ helps. Coefficient mass is the wrong objective for f.
- **Coppersmith threshold, univariate**: 31 bits works / 32 fails at N=2^128,
  X=N^(1/4) exactly. Nothing beats 1/2.
- **Rigorous L[1/2] exists** (Shoup Thm 15.6, unconditional since ~2009). The
  smoothness wall is a SUBGROUP wall, not a tooling artifact.
- **Bivariate recombination**: certify-and-split deletes the s·D term entirely,
  but recursion DEPTH remains the obstacle to beating Lecerf 1.5.

## 5. Where the genuinely open ground is

- **Stange Q-kernel** — the only method that worked (75% success). Memory says
  "first method in 48 rounds". Its regime gap is ~4.3 orders of magnitude.
- **The α ≥ 0.15 GIFP wall** — discovered THIS session (r111c), a genuine
  ceiling in the 2023 GIFP construction that `t=ceil` does not rescue. New
  observation about published work; not yet explained.
- **Class-group / smoothness structure** — whether an explicit smoothness
  assumption can be exploited rather than merely stated.

## 6. Output

Write your experiment under `factor-scratch/r112/<your-axis>/`. End with a short
`RESULT.md` containing: the claim, the falsifier, the exact command to reproduce,
the verified counts (twice, seeded), and an honest verdict. Do not commit — the
lead will review before anything lands.