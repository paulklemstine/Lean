# Two Kinds of Lines, One Hidden Grid

## How reticulations turn incidence geometry into cooperative arrays

A railway map and a spreadsheet seem to organize information in opposite ways. The map begins with lines and intersections: choose one route from each of two systems, and their crossing identifies a place. The spreadsheet begins with places already arranged in rows and columns, then records symbols in cells. Yet beneath these two pictures lies the same combinatorial mechanism. Once that mechanism is isolated, generalized nets, rectangular arrays, and families of Latin-like matrices become different languages for one structure.

The key object is a **reticulation**. Imagine a finite set $P$ of points and two types of line families, which we will call weft and warp. Each individual family partitions $P$: every point lies on exactly one line in that family. Weft lines have $m$ possible labels, warp lines have $n$ possible labels. The decisive rule is that whenever one chooses a weft family and a warp family, every selected pair of labels identifies exactly one point. In other words, a weft line and a warp line from the chosen families meet once and only once.

This simple crossing rule forces a hidden rectangular grid. Fix one weft family $u$ and one warp family $v$. Give each point $p$ its two line labels,

$$
p\longmapsto \bigl(w_u(p),z_v(p)\bigr),
$$

where $w_u(p)\in\{0,\ldots,m-1\}$ and $z_v(p)\in\{0,\ldots,n-1\}$. Unique intersection says precisely that this map is a bijection from $P$ to the grid

$$
\{0,\ldots,m-1\}\times\{0,\ldots,n-1\}.
$$

That observation is the engine behind every result discussed here.

## The unavoidable size of the point set

The first consequence is a counting theorem.

**Cardinality Theorem.** If a finite reticulation has $m$ labels on the weft side and $n$ labels on the warp side, and at least one family of each type is available, then its point set has exactly $mn$ elements.

The proof is almost visual. Choose one family of each type. Each point determines one ordered pair of labels, no two points determine the same pair, and every pair occurs. There are $m$ choices for the first label and $n$ for the second, so there are $mn$ points.

This is stronger than a mere count. It says that any chosen opposite-type pair of families provides a complete coordinate system for the same underlying set. Changing the pair changes the grid coordinates, but not the points. A reticulation is therefore not just one grid; it is a point set carrying many compatible grid views.

That perspective has practical resonance. A database record can carry several categorical descriptions. If every category from one group combines exactly once with every category from another, then any cross-group pair serves as a lossless compound key. In experimental design, this is perfect balance: every level pair appears exactly once. In communication systems, it resembles a pair of labels that decodes each state uniquely.

## From lines to matrices

Now fix a visible $m$-by-$n$ grid. A matrix $C$ assigns one of $m$ symbols to each cell. Call $C$ **column-Latin** when, within every column, each of its $m$ symbols appears exactly once. A second matrix $R$, using $n$ symbols, is **row-Latin** when, within every row, each of its $n$ symbols appears exactly once.

The adjective “Latin” evokes Latin squares, but the rectangular setting is asymmetric. A column-Latin matrix controls columns and uses $m$ symbols; a row-Latin matrix controls rows and uses $n$ symbols. Neither matrix is required to be Latin in both directions.

The pair becomes truly geometric through **orthogonality**. We say $C$ and $R$ are orthogonal when the map

$$
(i,j)\longmapsto \bigl(C(i,j),R(i,j)\bigr)
$$

is a bijection. Thus every ordered symbol pair $(q,r)$ occurs in exactly one cell.

A **cooperative pair** consists of a column-Latin matrix $C$, a row-Latin matrix $R$, and orthogonality between them. A **cooperative system** allows many column-Latin matrices and many row-Latin matrices, with every matrix from the first collection orthogonal to every matrix from the second. The matrices cooperate across the divide; no condition is imposed here between two members of the same collection.

Three exact regularity statements follow.

**Column Uniqueness.** In a column-Latin matrix, for every column $j$ and every symbol $q$, there is exactly one row $i$ with $C(i,j)=q$.

**Row Uniqueness.** In a row-Latin matrix, for every row $i$ and every symbol $r$, there is exactly one column $j$ with $R(i,j)=r$.

**Cross-Intersection Theorem.** In a cooperative pair, for every symbol pair $(q,r)$ there is exactly one cell $(i,j)$ satisfying both $C(i,j)=q$ and $R(i,j)=r$.

The first two statements unpack the two Latin conditions. The third unpacks orthogonality. Read geometrically, the cells carrying a fixed value $q$ of $C$ form a weft line, while the cells carrying a fixed value $r$ of $R$ form a warp line. Their unique common cell is the unique intersection of those lines.

## The coordinate matrices are universal reference frames

Two especially simple matrices are always present on an $m$-by-$n$ grid. The horizontal coordinate matrix is

$$
H(i,j)=i,
$$

and the vertical coordinate matrix is

$$
V(i,j)=j.
$$

Together they merely report the address of each cell. Consequently $(H,V)$ is a cooperative pair: $H$ lists all row labels once down each column, $V$ lists all column labels once across each row, and $(H(i,j),V(i,j))=(i,j)$.

More surprisingly, these coordinate matrices characterize the one-sided Latin properties.

**Coordinate Characterization Theorem.** A matrix $C$ with $m$ symbols is column-Latin if and only if $C$ is orthogonal to the vertical coordinate matrix $V$. Dually, a matrix $R$ with $n$ symbols is row-Latin if and only if the horizontal coordinate matrix $H$ is orthogonal to $R$.

Why? Pairing $C(i,j)$ with $V(i,j)=j$ records a symbol and its column. Bijectivity says that every symbol-column pair occurs exactly once, which is exactly the column-Latin rule. The dual argument pairs the row address $i$ with $R(i,j)$.

This theorem turns a local condition into a global one. “Every column is a permutation” can be replaced by “one map on the whole grid is bijective.” Such reformulations matter computationally: local scans and global pair counting become interchangeable tests.

## Three equivalent ways to hold the same information

A cooperative system immediately creates a reticulation. Treat grid cells as points. For each column-Latin matrix $C_u$, its fibres $C_u^{-1}(q)$ are the weft lines of family $u$. For each row-Latin matrix $R_v$, its fibres $R_v^{-1}(r)$ are the warp lines of family $v$. Cross-orthogonality supplies the unique-intersection rule.

It can also be written as a compact data table called a **svelte array**. Each grid cell becomes one row. Columns of the table are divided into a left group indexed by the column-Latin matrices and a right group indexed by the row-Latin matrices. In the row belonging to cell $p$, the left entry under $u$ is $C_u(p)$ and the right entry under $v$ is $R_v(p)$.

A svelte array is characterized by one condition: for every left column $u$, every right column $v$, and every pair of values $(q,r)$, exactly one table row has those two entries. Equivalently, projecting the table onto any one left and one right column gives every point of the $m$-by-$n$ value grid exactly once.

**Encoding Theorem.** Every cooperative system yields both a reticulation on its cells and a svelte array whose rows are those cells. For every chosen left-right coordinate pair and every value pair $(q,r)$, there is exactly one corresponding point and exactly one corresponding array row.

Conversely, reading the left and right entries of a svelte array as line labels produces a reticulation: fibres of a fixed entry become lines, and the defining projection property gives unique intersections. The row count is then forced.

**Svelte Array Size Theorem.** If a svelte array has left symbols drawn from a set of size $m$ and right symbols drawn from a set of size $n$, and it has at least one column of each type, then it has exactly $mn$ rows.

Thus geometry, matrices, and tables are not competing metaphors. Geometry emphasizes intersections, matrices emphasize permutations and orthogonality, and tables emphasize balanced projections. Each makes a different task easy.

## A small example

Take $m=3$ and $n=4$. On the twelve cells, define

$$
C(i,j)=i
$$

and

$$
R(i,j)=j.
$$

Every column of $C$ contains $0,1,2$ once; every row of $R$ contains $0,1,2,3$ once. Every pair $(q,r)$ appears at the unique cell $(q,r)$. The fibres $C^{-1}(q)$ are horizontal rows, while the fibres $R^{-1}(r)$ are vertical columns.

A less literal coordinate system can scramble the labels independently. For permutations $\sigma_j$ of the $m$ symbols, define $C(i,j)=\sigma_j(i)$. This remains column-Latin. Likewise, for permutations $\tau_i$ of the $n$ symbols, define $R(i,j)=\tau_i(j)$. It remains row-Latin. But cooperation is not automatic: one must still check that all pairs $(C(i,j),R(i,j))$ are distinct. The distinction is important. Local permutation balance is necessary, while orthogonality is the global compatibility that turns two balanced labelings into a geometry.

## Why this framework travels well

These structures belong to combinatorics, but their organizing principle appears wherever paired features must identify examples without collision. In machine learning, a balanced benchmark may be stratified by two attribute groups. Exact cross-balance ensures that every selected left-right category pair appears equally—in the svelte case, exactly once. In representation learning, multiple coordinate views can be judged by whether cross-view labels retain all information. In experimental design, orthogonality prevents confounding between factors. In data engineering, any opposite-type pair becomes a candidate key.

The framework also suggests efficient validation. To test a proposed cooperative pair on $mn$ cells, scan each column of $C$, each row of $R$, and all ordered pairs $(C(i,j),R(i,j))$. With hash tables or Boolean marker arrays, the work is linear in the number of cells, $O(mn)$, and the storage is $O(mn)$ in the most direct implementation. To build the associated svelte array, write one row per cell and one entry per matrix; for $a$ left matrices and $b$ right matrices, this costs $O(mn(a+b))$ time.

At the heart of all these applications is a modest but powerful idea: a unique crossing is a coordinate. Once every left line crosses every right line exactly once, counting, decoding, tabulation, and geometric incidence all become the same operation. The grid was there all along—not necessarily drawn, but forced by the logic of the intersections.