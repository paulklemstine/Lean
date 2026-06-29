# The Emotional Spectrum of Social Networks

## Why Your Friend Group Needs At Least Three Feelings

*In a world increasingly mapped by data, a surprising mathematical result reveals a deep connection between the structure of social networks and the minimum emotional complexity they can sustain.*

---

Picture a dinner party. Seven guests sit around a table, each carrying a mood — joyful, anxious, melancholic, serene. Now imagine the constraint that no two people who are close friends can be in the same emotional state at the same time. How many distinct emotional states does the group need?

This is not merely a thought experiment. It is a precise mathematical question, one that sits at the intersection of graph theory and the psychology of emotion. And its answer, it turns out, reveals something unexpectedly deep about the architecture of human connection.

## The Mathematics of Mood

Graph theory — the mathematics of networks — has been studying problems like this since Euler walked the bridges of Königsberg in 1736. A graph is simply a collection of nodes (people) connected by edges (relationships). A *proper coloring* of a graph assigns colors to nodes so that no two connected nodes share a color. The minimum number of colors needed is the graph's **chromatic number**, one of the most studied quantities in all of combinatorics.

The chromatic number captures something essential about a network's structure. A chain of people standing in a line needs only two colors — alternating back and forth works perfectly. But add a single connection that creates a triangle, and suddenly two colors aren't enough. Every triangle needs three.

What happens when we add a psychological constraint?

## The Three-Emotion Floor

Psychologists have long argued that human emotional experience requires a minimum vocabulary. Paul Ekman's classic work identifies six basic emotions; Robert Plutchik's wheel proposes eight. But even the most minimal models — those based on valence (positive/negative) and arousal (high/low) — require at least three distinguishable states: positive, negative, and neutral.

This observation leads to a natural mathematical definition. An **emotional coloring** of a social network is a proper coloring that uses at least three colors. The **emotional chromatic number** χ_E(G) is the minimum number of colors needed for such a coloring.

The question becomes: how does this psychological floor interact with the network's intrinsic structure?

## The Surprising Answer

The answer is elegant and, in retrospect, almost inevitable: the emotional chromatic number of any graph G equals the maximum of 3 and the ordinary chromatic number χ(G).

In symbols: **χ_E(G) = max(3, χ(G))**.

This means the psychological constraint — the requirement for at least three emotional states — is non-trivial *only* for the simplest possible social networks: those where everyone can be divided into just one or two groups with no intra-group friendships.

Think about what this means. If your social circle is complex enough to need four or more "colors" — four or more distinct emotional states to avoid conflict — then the psychological floor is irrelevant. The network's own structure already demands more complexity than psychology requires. It's only for the most structurally impoverished networks — a group of complete strangers, or a group that splits cleanly into two non-interacting factions — that the three-emotion minimum matters.

## The Pigeonhole Principle at Work

The proof of this result rests on one of mathematics' most intuitive principles: the **pigeonhole principle**. If you have more pigeons than holes, at least two pigeons must share a hole.

Applied to graph coloring: if a group of people are *all* friends with each other (forming what mathematicians call a **clique**), then every person in the clique needs a distinct color. A clique of five people needs five colors, period. No amount of cleverness in assigning colors can get around this fundamental bottleneck.

This principle establishes that the chromatic number of the complete graph on n vertices is exactly n. And it provides the lower bound for all graphs: if your network contains a clique of size k, you need at least k colors.

The emotional chromatic result then follows by observing that if a graph already needs k ≥ 3 colors, the emotional constraint adds nothing. And if it needs fewer than 3, we simply bump up to 3 — which is always possible because any proper 1-coloring or 2-coloring can trivially be extended to use 3 colors (just add unused colors to the palette).

## Tropical Geometry Enters the Scene

But the story doesn't end with this classification. A deeper connection emerges when we look at graph coloring through the lens of **tropical geometry**, a relatively new branch of mathematics that has been generating excitement across multiple fields.

In tropical mathematics, we replace the ordinary arithmetic operations: addition becomes minimum, and multiplication becomes addition. This seemingly bizarre substitution transforms smooth, curved mathematical objects into angular, piecewise-linear ones — like replacing a globe with an origami approximation. The tropical semiring (ℝ ∪ {∞}, min, +) preserves enough algebraic structure to make many classical theorems "tropicalize" into discrete, combinatorial versions.

When we apply this tropical lens to the chromatic polynomial — the polynomial that counts the number of proper k-colorings of a graph — something remarkable happens. The tropical version of this polynomial becomes a piecewise-linear function whose breakpoints encode structural information about the graph. The tropical chromatic evaluation, which combines the number of vertices and edges into a single tropical quantity, exhibits a clean monotonicity property: increasing the number of available colors can only improve or maintain the tropical value.

This monotonicity isn't merely a curiosity. It connects the combinatorial world of graph coloring to the continuous world of optimization and algebraic geometry. The breakpoints of the tropical chromatic function correspond to phase transitions in the coloring landscape — moments where adding one more color to the palette fundamentally changes what's possible.

## Implications for Social Science

What does all this mean for understanding real social networks?

First, it provides a clean mathematical framework for thinking about emotional diversity in groups. The **coloring diversity index** — the number of distinct emotions actually expressed in a network — is bounded both by the number of available emotions and by the size of the group. This dual constraint captures a genuine tension: small groups don't need many emotions, and limited emotional vocabularies can't support arbitrarily complex social structures.

Second, the max(3, χ(G)) formula suggests that most real social networks, which are far from bipartite, have emotional complexity dictated entirely by their structure — not by any psychological minimum. The three-emotion floor is only binding for the most primitive network topologies.

Third, the tropical connection opens the door to optimization-based approaches. If we can assign "costs" to emotional mismatches between connected individuals, the tropical framework provides a natural way to find optimal emotional configurations — ones that minimize the worst-case conflict.

## A Bridge Between Worlds

The emotional chromatic number sits at a crossroads. To its left lies classical combinatorics, with its elegant proofs and clean structural results. To its right lies tropical geometry, with its angular landscapes and algebraic power. Above it stands psychology, with its theories of emotion and social cognition. Below it lies network science, with its data-driven maps of human connection.

The mathematical result itself — χ_E(G) = max(3, χ(G)) — is, in a sense, a negative result. The emotional constraint doesn't create new mathematics for complex graphs. But this very simplicity is the insight: it tells us that the structure of social networks, not the palette of human emotions, is the binding constraint on social complexity. The network shapes the emotions it can sustain, not the other way around.

And in the tropical realm, where addition becomes minimum and multiplication becomes addition, even this simple result acquires new texture. The piecewise-linear landscape of tropical colorings reveals phase transitions invisible to classical analysis — moments where the mathematics of feeling shifts beneath our feet.

In mathematics, the deepest truths often hide in the simplest statements. The emotional chromatic number may be just max(3, χ(G)), but the journey to that formula — through pigeonholes and cliques, through tropical semirings and diversity indices — reveals a landscape far richer than the destination alone suggests.

---

*The research described here builds on foundational work in graph theory, tropical geometry, and the mathematics of social networks. The chromatic polynomial was introduced by George David Birkhoff in 1912. Tropical geometry emerged in the early 2000s from the work of mathematicians including Mikhalkin, Sturmfels, and Speyer.*
