import { Prisma } from "../prisma";

export async function FindEducation(PartType: string, Brand?: string, Model?: string) {
  if (Brand && Model) {
    const exact = await Prisma.partEducation.findFirst({
      where: { PartType, MotorBrand: Brand, MotorModel: Model }
    });
    if (exact) return { Education: exact, IsGeneric: false };
  }
  const generic = await Prisma.partEducation.findFirst({
    where: { PartType, MotorBrand: null, MotorModel: null }
  });
  return { Education: generic, IsGeneric: true };
}
