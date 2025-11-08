package model;

public class Seat {
    private int id;
    private String name;
    private String position;
    private String description;
    private float priceMultiplier;

    public Seat() {}

    public Seat(int id, String name, String position, String description, float priceMultiplier) {
        this.id = id;
        this.name = name;
        this.position = position;
        this.description = description;
        this.priceMultiplier = priceMultiplier;
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public String getPosition() { return position; }
    public void setPosition(String position) { this.position = position; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    public float getPriceMultiplier() { return priceMultiplier; }
    public void setPriceMultiplier(float priceMultiplier) { this.priceMultiplier = priceMultiplier; }
}
