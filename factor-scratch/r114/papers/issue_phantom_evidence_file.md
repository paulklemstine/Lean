**Title:** FACT r114: A PHANTOM LOCAL EVIDENCE FILE — the yoked-code refutation cited `r45/axis7/yoked_parallel.md` (592 lines), a file that was never committed, and the whole `factor-scratch/r45/axis7/` directory never existed

**Labels:** approved-direction

---

## New species: the fabrication was local, not bibliographic

This campaign has 16+ known **phantom citations** — invented references to papers that
do not exist. Round 114 found a **seventeenth failure of a different kind**: an invented
reference to a **local evidence file**, made convincing by a precise invented line count.

The memory entry `quantum-factoring-gap-yoked-parallel` was anchored on two files:

| Cited as | Location cited | Reality |
|---|---|---|
| "the survey in …" | `~/factor-scratch/r45/axis7/quantum_resources.md` | **does not exist** |
| "found it fails, for three independent reasons (…)" | `~/factor-scratch/r45/axis7/yoked_parallel.md`, **592 lines** | **does not exist** |

## Verification — two independent ways

**1. Filesystem.** The directory is absent and nothing matching exists anywhere:

```bash
$ ls factor-scratch/r45/axis7/
ls: cannot access 'factor-scratch/r45/axis7/': No such file or directory
$ find . -name "*yoked*" -not -path "./.git/*"
(no output)
$ find . -name "quantum_resources*" -not -path "./.git/*"
(no output)
$ find factor-scratch/r45 -name "*.md"
(no output — r45 contains no markdown at all)
```

**2. Full git history.** All 8,862 commits, every branch:

```bash
$ git rev-list --all --count
8862
$ git log --all --diff-filter=A --name-only --pretty=format: -- 'factor-scratch/r45/axis7/*'
(no output)
$ git log --all --name-only --pretty=format: -- 'factor-scratch/r45/**'
(no output — NO path under factor-scratch/r45 was EVER committed)
$ git log --all --name-only --pretty=format: -- '*quantum_resources*'
(no output)
```

So this is not a deleted file. **The entire `factor-scratch/r45/axis7/` directory is
fictional.**

## Why this one matters more than the usual phantom

**The conclusion was correct; only the provenance was fabricated.** Round 114's quantum
scout independently re-derived the refutation *from the primary sources* and reached the
same conclusion — so the entry's content stands, while its cited evidence never existed.

That is the inverse of the usual failure and strictly harder to catch: a right answer with
a fake citation looks correct to every downstream reader, and unlike a wrong claim it will
never be caught by a result being contradicted. The invented **"592 lines"** is what makes
it convincing — a fabricated file would normally be cited vaguely; the line count is a
fabricated *specific*, of exactly the kind that has fooled this campaign before.

**Second refutation it enables.** The entry claimed *"no paper connects the yoked-code
result to the parallelisation result."* **That is false.** Pinnacle's reference [8] *is*
Gidney arXiv:2505.15917 — the rho-parallelisation is built directly on top of the paper
containing the 61% cold store. The two were already joined in the literature.

## What IS verified (re-derived from primary sources, r114)

| Claim | Status |
|---|---|
| Gidney 2025 = arXiv:2505.15917 | VERIFIED (v1 only, no v2) |
| "61% cold storage" | VERIFIED — **61.30%**, arithmetic reproduced exactly |
| Yoked code, 430 physical qubits per logical | VERIFIED (Gidney p18) |
| Yoked code's identity | **UPGRADED** — it is peer-reviewed: Gidney, Newman, Brooks, Jones, *"Yoked surface codes"*, **Nature Communications 16, 4498** (14 May 2025), DOI `10.1038/s41467-025-59714-1`. Not a preprint, as this campaign recorded it. |
| Pinnacle = arXiv:2602.11457 | VERIFIED (Riverlane, 12 Feb 2026) |
| Pinnacle needs a read-only input register | VERIFIED (Sec. V.B.3) |
| "No paper joins them" | **REFUTED** — Pinnacle ref [8] *is* Gidney |

## The substantive result: the fusion is self-defeating

Re-derived independently, the yoked-code / rho-parallelisation fusion **fails**, and the
reason is structural rather than quantitative:

- **The yoked code prices IDLE qubits.** 61.3% of Gidney's machine is cold storage
  (550,400 / 897,864). rho-parallelisation multiplies the **working registers**, which are
  operated on continuously and therefore *cannot* use the yoked code. The marginal cost of
  one extra working register is ~206,856 physical qubits, of which the yoked code
  contributes **exactly 0**.
- **The enabling interface does not exist.** Pinnacle needs a non-destructive,
  concurrently shared CNOT-control port; the yoked paper says cold qubits "could not be
  immediately operated upon" and access hallways are blocked during measurement. Gidney
  flagged this himself (p20) as future work.
- **Pinnacle dominates it.** Best fusion point ~1.97e6 / 1.10e6 qubit-days versus
  Pinnacle's 9.45e5 and 3.33e5; Pinnacle's working register is 21,630 physical qubits
  versus the fusion's 206,856 — **9.6x denser.**

**Verdict: REFUTED.** The "clearest unexploited gap found anywhere in this campaign" was
not a gap. It was an artifact of two papers being read separately.

## Reproduction

```bash
ls factor-scratch/r45/axis7/                                  # No such file
find . -name "*yoked*" -not -path "./.git/*"                  # empty
find factor-scratch/r45 -name "*.md"                          # empty
git rev-list --all --count                                    # 8862
git log --all --diff-filter=A --name-only --pretty=format: -- 'factor-scratch/r45/axis7/*'
git log --all --name-only --pretty=format: -- 'factor-scratch/r45/**'
```

Full report: `factor-scratch/r114/qrs/RESULT.md`

## Threats to validity

1. The refutation of the fusion was **re-derived independently by an agent reading the
   papers directly**, and agrees with the original entry's content — so the *content* is
   double-sourced. The *provenance* is not.
2. We did **not** obtain Gidney's or Pinnacle's full PDFs through the agents' usual routes
   in every case; the load-bearing numbers (61.30%, 430:1) are quoted with page citations
   from the scout's fetch and were arithmetically reproduced, but a reader should re-verify
   against the PDFs before relying on the decimals.
3. `git log --diff-filter=A` shows files **added**; a file added outside git and later
   committed under a different path would not appear. The `find` and
   `git log --all -- 'factor-scratch/r45/**'` results independently rule this out for
   these paths.

## Process change this forces

**Cite local evidence the way we cite papers: with a command that proves it exists.**
The habit that would have caught this in one second:

```bash
test -f <cited-path> && wc -l <cited-path>
```

A cited local file that cannot be `wc -l`'d did not do any work.