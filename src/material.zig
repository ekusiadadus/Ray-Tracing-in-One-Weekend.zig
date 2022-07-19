const std = @import("std");
const math = std.math;
const rtw = @import("rtweekend.zig");
const vec = @import("vec.zig");
const ray = @import("ray.zig");
const hittable = @import("hittable.zig");

const Vec3 = rtw.Vec3;
const Color = rtw.Color;
const Ray = ray.Ray;
const SType = rtw.SType;
const HitRecord = hittable.HitRecord;
const RandGen = rtw.RandGen;

const f3 = rtw.f3;

pub const Material = union(enum) {
    Lambertian: Lambertian,
    Metal: Metal,

    pub fn lambertian(albedo: Vec3) Material {
        return Material{ .Lambertian = Lambertian{ .albedo = albedo } };
    }

    pub fn metal(albedo: Vec3, fuzz: SType) Material {
        return Material{ .Metal = Metal{ .albedo = albedo, .fuzz = fuzz } };
    }
};

const Lambertian = struct {
    albedo: Color,

    const Self = @This();

    pub fn scatter(self: Self, r_in: Ray, rec: HitRecord, attenuation: *Color, scattered: *Ray, rnd: *RandGen) bool {
        _ = r_in;
        var scatter_direction = rec.normal + vec.randomUnitVector(rnd, Color);

        if (vec.nearZero(scatter_direction)) {
            scatter_direction = rec.normal;
        }

        scattered.* = Ray{ .origin = rec.p, .direction = scatter_direction };
        attenuation.* = self.albedo;
        return true;
    }
};

const Metal = struct {
    albedo: Color,
    fuzz: SType,

    const Self = @This();

    pub fn scatter(self: Self, r_in: Ray, rec: HitRecord, attenuation: *Color, scattered: *Ray, rnd: *RandGen) bool {
        const reflected = vec.reflect(vec.unit(r_in.direction), rec.normal);
        scattered.* = Ray{ .origin = rec.p, .direction = reflected + f3(self.fuzz) * vec.randomInUnitSphere(rnd, Vec3) };
        attenuation.* = self.albedo;
        return vec.dot(scattered.direction, rec.normal) > 0.0;
    }
};
