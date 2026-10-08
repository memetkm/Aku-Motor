import { Router } from "express";
import { Prisma } from "../prisma";
import { FindEducation } from "../services/educationService";

export const EducationRoutes = Router();
export const PartEducationRoutes = Router();

EducationRoutes.get("/", async (_request, response) => {
  response.json(await Prisma.partEducation.findMany({ orderBy: { PartType: "asc" } }));
});

PartEducationRoutes.get("/:Id/education", async (request, response) => {
  const part = await Prisma.part.findUnique({ where: { Id: Number(request.params.Id) }, include: { Motor: true } });
  if (!part) return response.status(404).json({ Message: "Part tidak ditemukan." });
  const { Education, IsGeneric } = await FindEducation(part.PartType, part.Motor.Brand, part.Motor.Model);
  if (!Education) return response.status(404).json({ Message: "Materi edukasi belum tersedia." });
  response.json({ ...Education, IsGeneric });
});
