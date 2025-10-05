const std = @import("std");
const testing = std.testing;

const ExampleStruct = struct {
    l: std.ArrayList(u8),
};

test "ArrayList is freed by `deinit` as well" {
    var arena = std.heap.ArenaAllocator.init(testing.allocator);
    defer arena.deinit();

    _ = ExampleStruct{
        .l = std.ArrayList(u8).init(arena.allocator()),
    };
}

test "ArrayList can be reused after `reset`" {
    var arena = std.heap.ArenaAllocator.init(testing.allocator);
    defer arena.deinit();

    var s = ExampleStruct{
        .l = std.ArrayList(u8).init(arena.allocator()),
    };

    try s.l.append(1);
    try testing.expectEqual(@as(u8, 1), s.l.items[0]);

    // ---------------------------- retain capacity ----------------------------

    // OK
    // _ = arena.reset(.retain_capacity);
    // s.l.clearRetainingCapacity();

    // OK
    s.l.clearRetainingCapacity();
    _ = arena.reset(.retain_capacity);

    try testing.expectEqual(@as(usize, 0), s.l.items.len);

    try s.l.append(2);
    try testing.expectEqual(@as(usize, 1), s.l.items.len);
    try testing.expectEqual(@as(u8, 2), s.l.items[0]);

    // --------------------------------- free ----------------------------------

    // OK
    s.l.clearAndFree();
    _ = arena.reset(.free_all);

    // :( Segmentation fauld
    // _ = arena.reset(.free_all);
    // s.l.clearAndFree();

    try testing.expectEqual(@as(usize, 0), s.l.items.len);

    try s.l.append(3);
    try testing.expectEqual(@as(usize, 1), s.l.items.len);
    try testing.expectEqual(@as(u8, 3), s.l.items[0]);
}
