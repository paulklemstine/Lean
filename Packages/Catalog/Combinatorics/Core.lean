import Novelty.Core

/-!
# `Applications.Core` — the restriction algebra for agreement subtrees

This module is the `Applications` entry point for the split-system restriction algebra
(`SplitSystem`, `restrict`, `AgreeOn`, `CommonAgreement`, `IsAgreementThreshold`).  The
theory itself lives in `Novelty.Core`; re-exporting it here keeps a single copy of the
definitions, so that files importing `Applications.Core` and files importing
`Novelty.Core` share one and the same `AgreementSubtrees` namespace.
-/