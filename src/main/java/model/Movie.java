package model;

public class Movie {
    private int id;
    private String category;
    private String description;
    private String poster;
    private String name;
    private int active;

    public Movie() {}

    public Movie(int id, String category, String description, String poster, String name, int active) {
        this.id = id;
        this.category = category;
        this.description = description;
        this.poster = poster;
        this.name = name;
        this.active = active;
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public String getCategory() { return category; }
    public void setCategory(String category) { this.category = category; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    public String getPoster() { return poster; }
    public void setPoster(String poster) { this.poster = poster; }
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public int getActive() { return active; }
    public void setActive(int active) { this.active = active; }
}
