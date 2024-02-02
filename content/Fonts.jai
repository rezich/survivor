FONTS :: struct { name: string; size_denominator: int; }.[
    .{ "FLOATER"    , 48 },
    .{ "HUD_LARGE"  , 16 },
    .{ "HUD_MEDIUM" , 24 },
    .{ "HUD_SMALL"  , 36 },
    .{ "HUD_TINY"   , 48 }
];

#insert -> string {
    builder: String_Builder;
    append(*builder, "Font :: enum {\n");
    for FONTS print_to_builder(*builder, "    %;\n", it.name);
    append(*builder, "}\n");

    append(*builder, "FONT_SIZE_DENOMINATORS :: int.[\n");
    for FONTS print_to_builder(*builder, "    %,\n", it.size_denominator);
    append(*builder, "];\n");

    return builder_to_string(*builder);
}
