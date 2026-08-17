# Aether Future-Direction Pipeline Rework — Design

Date: 2026-08-16 · Scope: full-pipeline rework (minimal approach) · Rollout: straight to live

## 1. Problem statement

The future-direction system — the loop that turns a published research package's
`future_directions` into fresh pool entries for Phase A, and Phase A's result back into
publication at Phase B — has three stacked defects that were root-caused and **empirically
validated against the full real corpus: all 1186 pool/package future-direction blobs**
(568 `#`-prefixed pool descriptions + the `future_directions` field of every package JSON).

### 1.1 Root-cause bug: `_infer_domains` Bridges fallback

`research_memory.py` (~line 975) ends with `return domains or ["Bridges"]`. Every
domain-inference failure is therefore written as *bridges-only*, which `_is_quality_direction`
rejects via its bridges-only-without-`proof_strategy` clause. This single bug caused the original
**7 zero-add blobs** under v1 (content was fine; it was gated out by the fallback).

**Fix A (validated):** `infer_domains_v2` returns `[]` on failure — no `["Bridges"]` fallback.

### 1.2 Weak v1 splitter

`FutureDirectionsManager.add_directions_from_text` uses a 4-pattern cascade that cannot handle
the corpus's range of formats: structured `### Direction N:`, numbered-bold, plain-numbered,
`* ` / `- ` / `• ` bullets, sub-headed markdown sections, recap-versus-direction headers, and
pure prose fallbacks. Across the corpus it produced **326 junk titles** (bare numbers, recap
lead-ins like "What this cycle added", catch-all prose) and left real directions stranded inside
recap-classified sections.

### 1.3 Write-side merged-one injection

`knowledge_extractor.py` (~5013–5040) stores Phase B's output as **one merged
`future_directions` blob per cycle** — title = first non-header line, description = entire blob,
priority 0.75. **192 of the pool's 1540 directions are such whole-cycle merged blobs.** The
quality gate evaluates each merged blob as a single unit, so a rich multi-direction blob is
either rejected wholesale or survives with a junk title.

### 1.4 Robustness / honesty defects (found during the same analysis)

- **Tournament source protection:** `apply_tournament_outcomes` matches outcomes to pool
  directions with no source protection and killed the open GitHub issues NET-32–42 during a
  development round (it wrote outcomes onto directions that merely resembled the dispatched ones).
- **github_injector dedup:** the dedup check counts *pruned* directions, so an open issue whose
  direction was pruned is treated as already-injected and is never re-injected.
- **Phase B gate drift:** the gate's code does `p50 · clamp[0.25, 0.55]` while its docstring /
  filter name promises "top 30% / p70 / clamp[0.25, 0.70]" (with a `cache_version` bump in
  flight). Code and docstring must agree.

Goals addressed: research coherence/lineage (splitter + write-side), input-pipeline fidelity
(merged-one, tournament, github dedup), honest metrics/observability (gate reconciliation).

---

## 2. Section 1 — Robust split-on-add (splitter rework)

Replace the two functions in `research_memory.py` that form the shared core every injector
already routes through:

- `_infer_domains` → `infer_domains_v2`: same keyword scoring, **no `["Bridges"]` fallback
  (returns `[]`** on failure). The `"Bridges"` keyword itself stays — genuinely bridge-y
  directions still score it — only the failure fallback is removed.
- `add_directions_from_text` → section-aware cascade (validated prototype: `split_v2b`).

### 2.1 Cascade

1. **Recap-section stripping.** Split the blob into sections by markdown headers. Classify each
   header via `classify_header` using four stem sets:
   - `GENERIC_DIR_HEADERS` (= "future directions", "next steps", "open problems", "what remains",
     "where to go from here", …) → section marked **directions**; its header must never become a
     title.
   - `HARD_RECAP_STEMS` (summary, verdict, established, settled, survived, failed, scope,
     limitation, this delivery, evidence, proved, …) → **recap**, dropped. Narrow, not bare.
   - `RECAP_STEMS` / `DIR_STEMS` (soft sets) → disambiguate: direction-stem present and
     recap-stem absent → directions; both → recap only if proven-heavy (proved/established/
     settled/survived/failed present), else directions.
   - Tuning lesson from the audit: *bare* `results` and *bare* `what` over-strip legitimate
     sections ("Natural next results", "What remains") and were pulled out of the hard set;
     `remain(s/ing)` was added to the direction stems so "What remains" resolves to directions.
2. **Extraction cascade** (first pattern that yields items wins per blob):
   1. structured `### Direction N: <title>` (+ `Conjecture`/`Test`/`Impact`/`Proof Strategy`
      field extraction, catalog refs)
   2. numbered-bold `1. **Title** …`
   3. plain-numbered `1. Title. …` (split at `\d+\.`)
   4. bullets — regex **must include `* `, `- `, and `• `** (`* ` is Aether's most common marker)
      with a direction-verb gate for bullets outside explicitly-direction sections
   5. H2+ markdown headers (recap-classified skipped)
   6. paragraph fallback
3. **`clean_title` gate** applied uniformly to every candidate from every stage: strips
   markdown/list-number remnants; rejects recap lead-ins ("Derived from …", "What is now …",
   "We proved …"), metadata prefixes (status/remark/why-now/evidence/key-insight/scope/
   limitation/this-cycle), LaTeX / code-fence fragments, sentence-tail connectors
   ("that the …", "when `A` denotes …"), completion labels ("(N1) — proved", "S1 — settled"),
   bare labels, bare numbers, short lowercase fragments.

### 2.2 Validated results (isolated per blob, 1186 blobs, fixed style-based junk metric)

| metric | v1 current | v2b prototype |
|---|---|---|
| directions extracted | 4207 | **4661** (+11%) |
| zero-add blobs | 7 | **4** |
| junk titles | 326 | **0** |

- **All 7 original v1 zero-adds recovered**, e.g.:
  - `sonic_mathematics_counterpoint_as_category_theory` → *Diatonic-state quotient conjecture*,
    *Boundary-rule thinness conjecture*, *Seven-state strong-connectivity conjecture*, *Register
    sensitivity conjecture*, *Parallel-perfect repair conjecture* (5 clean directions).
  - `arxiv_paper_contractions_and_applications_of_cryst` → *Tableau-level crystal data*,
    *Bruhat identification*, *Weaker lifting hypotheses*, *Converse and counterexamples*, … (6).
  - `close_proofs_suspension_tower_sk_of_a_free__comple` (a mid-tuning regression, since fixed)
    → *Uniformize the obstruction to all n …*, *Extend the suspension tower …*, *Study the
    interaction …*, *Track explicit witnesses …* (4).
- **The 4 remaining zero-adds are defensible drops**: `statistical_mechanics_ising…`
  (every section is a results summary — v1 produced junk from it) and the NET-lab experiment
  writeup logs `fd_1231` / `fd_1239` / `fd_1317` (raw result logs with no future-direction
  section — v1 turned their recap subheaders into junk).

### 2.3 Dependencies

The section splitter, classifier, and `clean_title` become `research_memory` module functions;
`add_directions_from_text` delegates to them. No new modules.

---

## 3. Section 2 — Write-side: stop squandering quality on merged-one injections

At the Phase B injection site (`knowledge_extractor.py` ~5013), run the Section-1 splitter on
the freshly assembled blob **before** storing it, and store each extracted direction as its own
pool entry (normal quality gate + dedup per direction). Keep the merged blob only as a fallback
when the splitter decomposes nothing (defensible: pure-recap writeups).

Effect: the pool stops growing merged whole-cycle blobs; 192 existing merged blobs remain until
consumed or pruned by the existing machinery (no migration needed).

---

## 4. Section 3 — Tournament source protection

`apply_tournament_outcomes` must apply an outcome **only to the exact directions the tournament
dispatched**, matched by direction ID captured at dispatch time — never by re-matching
title/theme/domains against the (mutated) pool. Unmatched outcome records are logged and left
untouched. This prevents outcome write-back from clobbering unrelated open issues (the
NET-32–42 incident).

---

## 5. Section 4 — Honest measurement

- **Phase B gate reconciliation:** decide the intended gate, then make code and docstring agree.
  Fallback decision: keep the code's behavior (move docstring/filter naming to match); the
  decision and the old-vs-new table go in a comment at the gate. A regression test pins the
  docstring to the code.
- **github_injector dedup:** count **live** (non-pruned) directions only when deciding whether an
  open issue is already injected, so pruned directions don't strand their issues forever.

---

## 6. Integration & rollout

- All changes live in existing modules: `research_memory.py`, `knowledge_extractor.py`, the
  tournament outcome matcher, `github_injector.py`, Phase B gate.
- No new services, no workflow changes, no schema migration. New fields additive only.
- Rollout **straight to live** (per user choice). Flagged caveat: Section 2 changes what future
  Phase B runs write to the pool, so the first post-landing run diverges from the historical
  pool shape — that is the intended correction, and the existing pruned / selection-log
  machinery absorbs it.

## 7. Testing

- **Splitter unit tests** from the corpus audit: one test per format class (structured,
  numbered-bold, plain-numbered, `* `/`- `/`• ` bullets, H2 headers, paragraph) plus the
  rejection cases (recap section, generic header never a title, recap lead-in, sentence-tail,
  metadata prefix, LaTeX fragment).
- **Fix A test:** domain-failure direction preserves an empty domain list and still passes the
  quality gate.
- **Corpus regression test:** the 1186-blob harness with the three metrics frozen (≥ 4661 /
  ≤ 4 / 0).
- **Gate-drift regression:** code/docstring parity on the Phase B gate.
- **Tournament source-match test:** outcome applies only to dispatched IDs.
- **github_injector test:** pruned direction does not block re-injection of its issue.

---

## 8. Out of scope

- Repairing or re-splitting the 192 existing merged blobs (handled by consumption/pruning).
- Deep-dive format recovery for the NET-lab writeup logs beyond what Section 1 already yields.
- Any change to the quality-scoring formula itself (`_compute_quality_score`).