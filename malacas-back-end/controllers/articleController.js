const Article = require('../models/Article');

// GET all articles
const getArticles = async (req, res) => {
    try {
        const articles = await Article.find();
        res.json({ articles });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// CREATE new article
const createArticle = async (req, res) => {
    try {
        const article = await Article.create(req.body);
        res.status(201).json(article);
    } catch (error) {
        res.status(400).json({ message: error.message });
    }
};

// UPDATE article
const updateArticle = async (req, res) => {
    try {
        const article = await Article.findByIdAndUpdate(
            req.params.id,
            req.body,
            { new: true }   // ✅ fixed "nw" typo
        );
        res.json(article);
    } catch (error) {
        res.status(400).json({ message: error.message });
    }
};

// TOGGLE active status
const toggleArticleStatus = async (req, res) => {
    try {
        const article = await Article.findById(req.params.id); // ✅ fixed "param" typo
        if (!article) return res.status(404).json({ message: "Article not found" });

        article.isActive = !article.isActive;  // ✅ fixed wrong property
        await article.save();

        res.json(article);
    } catch (error) {
        res.status(400).json({ message: error.message });
    }
};

// GET article by name
const getArticleByName = async (req, res) => {
    try {
        const article = await Article.findOne({ name: req.params.name, isActive: true });
        if (!article) {
            return res.status(404).json({ message: 'Article not found' });
        }
        res.json({ article });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

module.exports = { getArticles, createArticle, updateArticle, toggleArticleStatus, getArticleByName };
