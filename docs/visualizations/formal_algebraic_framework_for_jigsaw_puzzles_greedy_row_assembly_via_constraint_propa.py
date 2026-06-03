def greedy_row_assembly(first_piece, length):
    row = [first_piece]
    for i in range(1, length):
        required_left = complement(row[-1].right)
        row.append(Piece(FLAT, TAB, FLAT, required_left))
    return row