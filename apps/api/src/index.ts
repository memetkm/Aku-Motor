import "dotenv/config";
import { App } from "./app";

const Port = Number(process.env.PORT ?? 4000);
App.listen(Port, () => console.log(`API Aku Motor berjalan di http://localhost:${Port}`));
