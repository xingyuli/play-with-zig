const std = @import("std");
const testing = std.testing;

const CustType = struct {
    a: i32,
    b: f64,
    c: bool,
};

const CustTypeWithJsonValue = struct {
    a: i32,
    b: f64,
    c: std.json.Value,
};

// Won't compile when std.json.stringify
const CustTypeWithJsonParsed = struct {
    a: i32,
    b: f64,
    c: std.json.Parsed(std.json.Value),
};

// Won't compile when std.json.stringify
const CustTypeWithJsonObjectMap = struct {
    a: i32,
    b: f64,
    c: std.json.ObjectMap,
};

test "stringify single CustType" {
    const json_str = try std.json.stringifyAlloc(
        testing.allocator,
        CustType{ .a = 1, .b = 1.0, .c = true },
        .{},
    );
    defer testing.allocator.free(json_str);

    try testing.expectEqualStrings(
        "{\"a\":1,\"b\":1e0,\"c\":true}",
        json_str,
    );
}

test "stringify slice of CustType" {
    const slice = [_]CustType{
        CustType{ .a = 1, .b = 1.0, .c = true },
        CustType{ .a = 2, .b = 2.0, .c = false },
    };

    const json_str = try std.json.stringifyAlloc(testing.allocator, slice, .{});
    defer testing.allocator.free(json_str);

    try testing.expectEqualStrings(
        "[{\"a\":1,\"b\":1e0,\"c\":true},{\"a\":2,\"b\":2e0,\"c\":false}]",
        json_str,
    );
}

test "stringify slice of CustTypeWithJsonValue" {
    const slice = [_]CustTypeWithJsonValue{
        CustTypeWithJsonValue{ .a = 1, .b = 1.0, .c = std.json.Value{ .integer = 1 } },
        CustTypeWithJsonValue{ .a = 2, .b = 2.0, .c = std.json.Value{ .integer = 2 } },
    };

    const json_str = try std.json.stringifyAlloc(testing.allocator, slice, .{});
    defer testing.allocator.free(json_str);

    try testing.expectEqualStrings(
        "[{\"a\":1,\"b\":1e0,\"c\":1},{\"a\":2,\"b\":2e0,\"c\":2}]",
        json_str,
    );
}

// ----------------------------------------------------------------------------
// -------------- won't compile: value should be comptime-known ---------------
// ----------------------------------------------------------------------------

// test "stringify slice of CustTypeWithJsonParsed" {
//     const slice = [_]CustTypeWithJsonParsed{
//         CustTypeWithJsonParsed{
//             .a = 1,
//             .b = 1.0,
//             .c = try std.json.parseFromSlice(std.json.Value, testing.allocator, "1", .{}),
//         },
//         CustTypeWithJsonParsed{
//             .a = 2,
//             .b = 2.0,
//             .c = try std.json.parseFromSlice(std.json.Value, testing.allocator, "2", .{}),
//         },
//     };

//     _ = try std.json.stringifyAlloc(testing.allocator, slice, .{});

//     unreachable;
// }

// test "stringify slice of CustTypeWithJsonObjectMap" {
//     var m1 = std.json.ObjectMap.init(testing.allocator);
//     defer m1.deinit();
//     try m1.put("a", std.json.Value{ .integer = 1 });
//     try m1.put("b", std.json.Value{ .float = 1.0 });

//     var m2 = std.json.ObjectMap.init(testing.allocator);
//     defer m2.deinit();
//     try m2.put("a", std.json.Value{ .integer = 2 });
//     try m2.put("b", std.json.Value{ .float = 2.0 });

//     const slice = [_]CustTypeWithJsonObjectMap{
//         CustTypeWithJsonObjectMap{ .a = 1, .b = 1.0, .c = m1 },
//         CustTypeWithJsonObjectMap{ .a = 2, .b = 2.0, .c = m2 },
//     };

//     _ = try std.json.stringifyAlloc(testing.allocator, slice, .{});

//     unreachable;
// }
