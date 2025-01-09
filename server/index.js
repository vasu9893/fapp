const express = require("express");
const mongoose = require("mongoose");
const authRouter = require("./routes/auth");

const PORT = process.env.PORT || 3000;
const app = express();

app.use(express.json());
app.use( authRouter);

const DB = "mongodb+srv:vasu:Vr812016984@cluster0.71son.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0"

mongoose.connect(DB).then(() => {
    console.log("Connected to MongoDB");
}).catch((err) => {
    console.log(err);
});

app.listen(PORT, "0.0.0.0", () => {     
    console.log(`Server is running on port ${PORT}`);

});
