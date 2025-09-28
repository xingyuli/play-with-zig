const std = @import("std");

const ExampleStruct = struct {
    v: i32,
};

const ExampleWrapper = struct {
    s: ExampleStruct,
    saved_addr_of_s: *const ExampleStruct,
    saved_addr_of_wrapper_s: ?*const ExampleStruct = null,

    fn printString(self: *const ExampleWrapper) void {
        std.debug.print("--- printString\n", .{});
        std.debug.print(
            "saved_addr_of_s: {*}\nsaved_addr_of_wrapper_s: {*}\nfresh addr of wrapper.s: {*}\n",
            .{ self.saved_addr_of_s, self.saved_addr_of_wrapper_s, &self.s },
        );
    }
};

test "use local pointer" {
    const s = ExampleStruct{ .v = 1 };

    const pointer_a = &s;
    const pointer_b = &s;

    try std.testing.expectEqual(pointer_a, pointer_b);
}

test "use copy of struct" {
    std.debug.print("\n\n=== use copy of struct\n", .{});

    const s = ExampleStruct{ .v = -1 };
    std.debug.print("addr of s: {*}\n", .{&s});

    const wrapper = createWrapperWithCopyOfStruct(s);
    wrapper.printString();

    std.debug.print("--- in test case\n", .{});
    std.debug.print("fresh addr of wrapper.s manually: {*}\n", .{&wrapper.s});

    try std.testing.expect(wrapper.saved_addr_of_s != &s);
    try std.testing.expect(wrapper.saved_addr_of_wrapper_s.? != wrapper.saved_addr_of_s);

    try std.testing.expect(&wrapper.s != &s);
    try std.testing.expect(&wrapper.s != wrapper.saved_addr_of_s);
    try std.testing.expect(&wrapper.s != wrapper.saved_addr_of_wrapper_s.?);
}

test "use pointer" {
    std.debug.print("\n\n=== use pointer\n", .{});

    const wrapper = createWrapper();
    wrapper.printString();

    std.debug.print("--- in test case\n", .{});
    std.debug.print("fresh addr of wrapper.s manually: {*}\n", .{&wrapper.s});

    try std.testing.expect(wrapper.saved_addr_of_wrapper_s != wrapper.saved_addr_of_s);

    try std.testing.expect(&wrapper.s != wrapper.saved_addr_of_s);
    try std.testing.expect(&wrapper.s != wrapper.saved_addr_of_wrapper_s.?);
}

fn createWrapperWithCopyOfStruct(s: ExampleStruct) ExampleWrapper {
    std.debug.print("--- in createWrapperWithCopyOfStruct\n", .{});

    var result = ExampleWrapper{ .s = s, .saved_addr_of_s = &s };
    result.saved_addr_of_wrapper_s = &result.s;
    return result;
}

fn createWrapper() ExampleWrapper {
    std.debug.print("--- in createWrapper\n", .{});

    var s = ExampleStruct{ .v = 1 };
    std.debug.print("addr of s: {*}\n", .{&s});

    var result = ExampleWrapper{ .s = s, .saved_addr_of_s = &s };
    result.saved_addr_of_wrapper_s = &result.s;
    return result;
}
