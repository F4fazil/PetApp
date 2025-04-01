class OnboardingContents {
  final String title;
  final String image;
  final String desc;

  OnboardingContents({
    required this.title,
    required this.image,
    required this.desc,
  });
}

List<OnboardingContents> contents = [
  OnboardingContents(
    title: "Welcome to PetPalace!",
    image: "assets/images/animal_care.png",
    desc:
        "Find everything your pet needs—food, vets, sitters, and more—all in one place!",
  ),
  OnboardingContents(
    title: "Healthy & Happy Pets!",
    image: "assets/images/petsitter.png",
    desc:
        "Get expert food recommendations and care tips tailored to your pet’s breed and needs!",
  ),
];
